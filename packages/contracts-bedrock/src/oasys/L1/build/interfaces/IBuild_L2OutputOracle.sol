// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuild_L2OutputOracle {
    function deployBytecode(
        uint256 l2OutputOracleSubmissionInterval,
        uint256 l2BlockTime,
        uint256 finalizationPeriodSeconds
    ) external pure returns (bytes memory);
}
