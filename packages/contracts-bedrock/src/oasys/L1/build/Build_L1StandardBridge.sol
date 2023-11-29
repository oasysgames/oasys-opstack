// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract Build_L1StandardBridge is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() public pure returns (bytes memory) {
        return type(L1StandardBridge).creationCode;
    }
}
