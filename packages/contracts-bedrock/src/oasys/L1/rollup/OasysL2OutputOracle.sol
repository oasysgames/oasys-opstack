// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { L2OutputOracle } from "../../L1/L2OutputOracle.sol";
import { Lib_OVMCodec } from "./legacy/Lib_OVMCodec.sol";
import { PredeployAddresses } from "./legacy/PredeployAddresses.sol";

/// @custom:proxied
/// @title OasysL2OutputOracle
/// @notice Extend the OptimismPortal to controll L2 timestamp and block number
contract OasysL2OutputOracle is L2OutputOracle {
    /// @notice Assign fresh number due to oasys custom logic
    /// @custom:semver 1.0.0
    // string public constant version = "1.0.0";

    uint256 public nextIndex;

    event StateBatchVerified(uint256 indexed _batchIndex, bytes32 _batchRoot);
    event StateBatchFailed(uint256 indexed _batchIndex, bytes32 _batchRoot);

    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _finalizationPeriodSeconds
    ) L2OutputOracle(_submissionInterval, _l2BlockTime, _finalizationPeriodSeconds) {}

    /// @notice Override to pass zero value of `startingBlockNumber` and `startingTimestamp`
    function initialize(address _proposer, address _challenger) public {
        // pass zero value of `startingBlockNumber` and `startingTimestamp`
        initialize(
            0, // startingBlockNumber
            0, // startingTimestamp
            _proposer,
            _challenger
        );

        // nextIndex = startingBlockNumber;
    }

    /// @notice Overrite to compute l2 block number and timestamp when the first l2 block is submitted
    function proposeL2Output(
        bytes32 _outputRoot,
        uint256 _l2BlockNumber,
        bytes32 _l1BlockHash,
        uint256 _l1BlockNumber
    ) public payable override {
        // compute l2 block number and timestamp when the first l2 block is submitted
        if (latestBlockNumber() == 0) {
            startingBlockNumber = _l2BlockNumber - SUBMISSION_INTERVAL;
            startingTimestamp = block.timestamp - L2_BLOCK_TIME * SUBMISSION_INTERVAL - 1;
            nextIndex = startingBlockNumber;
        }

        super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
    }

    /**
     * Method called by the OasysStateCommitmentChainVerifier after a verification successful.
     * @param _batchHeader Target batch header.
     */
    function succeedVerification(Lib_OVMCodec.ChainBatchHeader memory _batchHeader) external {
        require(msg.sender == PredeployAddresses.SCC_VERIFIER, "Invalid message sender.");

        require(_isValidBatchHeader(_batchHeader), "Invalid batch header.");

        require(_batchHeader.batchIndex == nextIndex, "Invalid batch index.");

        nextIndex += SUBMISSION_INTERVAL;

        emit StateBatchVerified(_batchHeader.batchIndex, _batchHeader.batchRoot);
    }

    /**
     * Checks that a batch header matches the stored hash for the given index.
     * @param _batchHeader Batch header to validate.
     * @return Whether or not the header matches the stored one.
     */
    function _isValidBatchHeader(
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    ) internal view returns (bool) {
        return _batchHeader.batchRoot == getL2OutputAfter(_batchHeader.batchIndex).outputRoot;
    }

    //     // /// @notice Returns the L2 timestamp corresponding to a given L2 block number.
    //     // /// @param _l2BlockNumber The L2 block number of the target block.
    //     // /// @return L2 timestamp of the given block.
    //     // function computeL2Timestamp(uint256 _l2BlockNumber) public override view returns (uint256) {
    //     //     if (l2Outputs.length == 0) {
    //     //         return 0;
    //     //     }
    //     //     return l2Outputs[l2Outputs.length - 1].timestamp - SUBMISSION_INTERVAL*L2_BLOCK_TIME
    //     // }
}
