// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Constants } from "src/libraries/Constants.sol";
import { Types } from "src/libraries/Types.sol";
import { Hashing } from "src/libraries/Hashing.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { IOasysL2OutputOracle } from "src/oasys/L1/interfaces/IOasysL2OutputOracle.sol";
import { IOasysL2OutputOracleVerifier } from "src/oasys/L1/interfaces/IOasysL2OutputOracleVerifier.sol";

/// @custom:proxied
/// @title OasysL2OutputOracle
/// @notice The OasysL2OutputOracle is a contract that extends
///         L2OutputOracle to enable instant verification.
contract OasysL2OutputOracle is IOasysL2OutputOracle, L2OutputOracle {
    /// @notice Address of the OasysL2OutputOracleVerifier contract.
    ///         This will be removed in the future, use `l2OracleVerifier` instead.
    /// @custom:legacy
    IOasysL2OutputOracleVerifier public immutable VERIFIER;

    /// @notice Next L2Output index to verify.
    uint256 public nextVerifyIndex;

    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp,
        address _proposer,
        address _challenger,
        uint256 _finalizationPeriodSeconds,
        IOasysL2OutputOracleVerifier _verifier
    )
        L2OutputOracle(
            _submissionInterval,
            _l2BlockTime,
            _startingBlockNumber,
            _startingTimestamp,
            _proposer,
            _challenger,
            _finalizationPeriodSeconds
        )
    {
        VERIFIER = _verifier;
    }

    /// @notice Initializer.
    /// @param _startingBlockNumber Block number for the first recoded L2 block.
    /// @param _startingTimestamp   Timestamp for the first recoded L2 block.
    function initialize(uint256 _startingBlockNumber, uint256 _startingTimestamp) public override {
        super.initialize(_startingBlockNumber, _startingTimestamp);
    }

    /// @notice Update the starting block number and timestamp.
    ///         Anyone can call, until the first output is recorded or deleted all the outputs.
    ///         This function for the purpose of attempting the L2 upgrade again,
    ///         after the L2 Upgrade fails and rollback operations are conducted.
    /// @param _startingBlockNumber Block number for the first recoded L2 block.
    /// @param _startingTimestamp   Timestamp for the first recoded L2 block.
    function updateStartingBlock(uint256 _startingBlockNumber, uint256 _startingTimestamp) public {
        require(
            _startingTimestamp <= block.timestamp,
            "L2OutputOracle: starting L2 timestamp must be less than current time"
        );
        require(l2Outputs.length == 0, "L2OutputOracle: cannot update starting block after outputs have been recorded");

        startingTimestamp = _startingTimestamp;
        startingBlockNumber = _startingBlockNumber;
    }

    /// @notice Getter function for the address of the OasysL2OutputOracleVerifier on this chain.
    /// @notice Address of the OasysL2OutputOracleVerifier on this chain.
    function l2OracleVerifier() public view returns (IOasysL2OutputOracleVerifier) {
        return VERIFIER;
    }

    /// @inheritdoc IOasysL2OutputOracle
    function succeedVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external {
        require(msg.sender == address(VERIFIER), "OasysL2OutputOracle: caller is not allowed");

        require(_isValidL2Output(l2OutputIndex, l2Output), "OasysL2OutputOracle: invalid output root");

        require(l2OutputIndex == nextVerifyIndex, "OasysL2OutputOracle: invalid L2 output index");

        nextVerifyIndex++;

        emit OutputVerified(l2OutputIndex, l2Output.outputRoot, l2Output.l2BlockNumber);
    }

    /// @inheritdoc IOasysL2OutputOracle
    function failVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external {
        require(msg.sender == address(VERIFIER), "OasysL2OutputOracle: caller is not allowed");

        require(_isValidL2Output(l2OutputIndex, l2Output), "OasysL2OutputOracle: invalid output root");

        _deleteL2Outputs(l2OutputIndex);

        emit OutputFailed(l2OutputIndex, l2Output.outputRoot, l2Output.l2BlockNumber);
    }

    /// @inheritdoc L2OutputOracle
    function deleteL2Outputs(uint256 l2OutputIndex) external override {
        require(msg.sender == challenger, "OasysL2OutputOracle: only the challenger address can delete outputs");

        _deleteL2Outputs(l2OutputIndex);
    }

    /// @inheritdoc IOasysL2OutputOracle
    function verifiedL1Timestamp() external view returns (uint128) {
        return nextVerifyIndex == 0 ? 0 : l2Outputs[nextVerifyIndex - 1].timestamp;
    }

    /// @inheritdoc IOasysL2OutputOracle
    function isOutputFinalized(uint256 l2OutputIndex) external view returns (bool) {
        return _isOutputFinalized(l2OutputIndex);
    }

    function _deleteL2Outputs(uint256 l2OutputIndex) internal {
        // Make sure we're not *increasing* the length of the array.
        require(
            l2OutputIndex < l2Outputs.length, "OasysL2OutputOracle: cannot delete outputs after the latest output index"
        );

        require(
            _isOutputFinalized(l2OutputIndex) == false,
            "OasysL2OutputOracle: cannot delete outputs that have already been finalized"
        );

        uint256 prevNextL2OutputIndex = nextOutputIndex();

        // Use assembly to delete the array elements because Solidity doesn't allow it.
        assembly {
            sstore(l2Outputs.slot, l2OutputIndex)
        }

        emit OutputsDeleted(prevNextL2OutputIndex, l2OutputIndex);
    }

    function _isValidL2Output(
        uint256 l2OutputIndex,
        Types.OutputProposal calldata actual
    )
        internal
        view
        returns (bool)
    {
        require(l2OutputIndex < l2Outputs.length, "OasysL2OutputOracle: l2OutputIndex out of bounds");

        Types.OutputProposal memory expect = l2Outputs[l2OutputIndex];
        return keccak256(abi.encodePacked(actual.outputRoot, actual.timestamp, actual.l2BlockNumber))
            == keccak256(abi.encodePacked(expect.outputRoot, expect.timestamp, expect.l2BlockNumber));
    }

    function _isOutputFinalized(uint256 l2OutputIndex) internal view returns (bool) {
        require(l2OutputIndex < l2Outputs.length, "OasysL2OutputOracle: l2OutputIndex out of bounds");

        if (l2OutputIndex < nextVerifyIndex) {
            return true;
        }
        //slither-disable-next-line block-timestamp
        if (block.timestamp - l2Outputs[l2OutputIndex].timestamp > finalizationPeriodSeconds) {
            return true;
        }
        return false;
    }
}
