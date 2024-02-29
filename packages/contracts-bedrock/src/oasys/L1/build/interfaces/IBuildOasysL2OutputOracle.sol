// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuildOasysL2OutputOracle {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _submissionInterval        Interval in blocks at which checkpoints must be submitted.
    /// @param _l2BlockTime               The time per L2 block, in seconds.
    /// @param _proposer                  The address of the proposer.
    /// @param _challenger                The address of the challenger.
    /// @param _finalizationPeriodSeconds The minimum time (in seconds) that must
    ///                                   elapse before a withdrawal can be finalized.
    /// @param _verifier                  The address of the OasysL2OutputOracleVerifier contract.
    function deployBytecode(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        address _proposer,
        address _challenger,
        uint256 _finalizationPeriodSeconds,
        address _verifier
    )
        external
        pure
        returns (bytes memory);

    /// @notice Return data for initializer.
    /// @param _startingBlockNumber The number of the first L2 block.
    /// @param _startingTimestamp   The timestamp of the first L2 block.
    function initializeData(
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp
    )
        external
        pure
        returns (bytes memory);
}
