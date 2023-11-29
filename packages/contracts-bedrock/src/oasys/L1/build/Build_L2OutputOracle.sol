// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Semver } from "../../universal/Semver.sol";
import { L2OutputOracle } from "../../L1/L2OutputOracle.sol";

// import { L2OutputOracle } from "../L1/OasysL2OutputOracle.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract Build_L2OutputOracle is Semver {
    constructor() Semver(1, 0, 0) {}

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode(
        uint256 l2OutputOracleSubmissionInterval,
        uint256 l2BlockTime,
        uint256 finalizationPeriodSeconds
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                abi.encodePacked(type(L2OutputOracle).creationCode),
                abi.encode(l2OutputOracleSubmissionInterval, l2BlockTime, finalizationPeriodSeconds)
            );
    }
}
