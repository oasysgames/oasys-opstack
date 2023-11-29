// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { IBuildL2OutputOracle } from "src/oasys/L1/build/interfaces/IBuildL2OutputOracle.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL2OutputOracle is IBuildL2OutputOracle, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode(
        uint256 l2OutputOracleSubmissionInterval,
        uint256 l2BlockTime,
        uint256 finalizationPeriodSeconds
    )
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            abi.encodePacked(type(L2OutputOracle).creationCode),
            abi.encode(l2OutputOracleSubmissionInterval, l2BlockTime, finalizationPeriodSeconds)
        );
    }
}
