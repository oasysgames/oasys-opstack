// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Constants } from "src/libraries/Constants.sol";
import { Types } from "src/libraries/Types.sol";
import { Hashing } from "src/libraries/Hashing.sol";
import { PredeployAddresses } from "src/oasys/L1/build/legacy/PredeployAddresses.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { IOasysL2OutputOracle } from "src/oasys/L1/interfaces/IOasysL2OutputOracle.sol";

/// @custom:proxied
/// @title OasysL2OutputOracle
/// @notice Extend the OptimismPortal to controll L2 timestamp and block number
contract OasysL2OutputOracle is IOasysL2OutputOracle, L2OutputOracle {
    /// @notice Next L2Output index to verify.
    uint256 public nextVerifyIndex;

    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp,
        address _proposer,
        address _challenger,
        uint256 _finalizationPeriodSeconds
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
    { }

    /// @notice Initializer.
    /// @param _startingBlockNumber Block number for the first recoded L2 block.
    /// @param _startingTimestamp   Timestamp for the first recoded L2 block.
    function initialize(uint256 _startingBlockNumber, uint256 _startingTimestamp) public override {
        super.initialize(_startingBlockNumber, _startingTimestamp);
    }

    /// @inheritdoc IOasysL2OutputOracle
    function succeedVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external {
        require(msg.sender == PredeployAddresses.SCC_VERIFIER, "OasysL2OutputOracle: caller is not allowed");

        require(_isValidL2Output(l2OutputIndex, l2Output), "OasysL2OutputOracle: invalid output root");

        require(l2OutputIndex == nextVerifyIndex, "OasysL2OutputOracle: invalid L2 output index");

        nextVerifyIndex++;

        emit OutputVerified(l2OutputIndex, l2Output.outputRoot, l2Output.l2BlockNumber);
    }

    /// @inheritdoc IOasysL2OutputOracle
    function failVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external {
        require(msg.sender == PredeployAddresses.SCC_VERIFIER, "OasysL2OutputOracle: caller is not allowed");

        require(_isValidL2Output(l2OutputIndex, l2Output), "OasysL2OutputOracle: invalid output root");

        _deleteL2Outputs(l2OutputIndex);

        emit OutputFailed(l2OutputIndex, l2Output.outputRoot, l2Output.l2BlockNumber);
    }

    /// @inheritdoc L2OutputOracle
    function deleteL2Outputs(uint256 l2OutputIndex) external override {
        require(msg.sender == CHALLENGER, "OasysL2OutputOracle: only the challenger address can delete outputs");

        _deleteL2Outputs(l2OutputIndex);
    }

    /// @inheritdoc IOasysL2OutputOracle
    function verifiedBlockNumber() external view returns (uint256) {
        return nextVerifyIndex * SUBMISSION_INTERVAL;
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
        Types.OutputProposal memory expect = l2Outputs[l2OutputIndex];
        return keccak256(abi.encodePacked(actual.outputRoot, actual.timestamp, actual.l2BlockNumber))
            == keccak256(abi.encodePacked(expect.outputRoot, expect.timestamp, expect.l2BlockNumber));
    }

    function _isOutputFinalized(uint256 l2OutputIndex) internal view returns (bool) {
        if (l2OutputIndex < nextVerifyIndex) {
            return true;
        }
        if (block.timestamp - l2Outputs[l2OutputIndex].timestamp > FINALIZATION_PERIOD_SECONDS) {
            return true;
        }
        return false;
    }
}
