// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract Build_SystemConfig is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() public pure returns (bytes memory) {
        return type(SystemConfig).creationCode;
    }
}
