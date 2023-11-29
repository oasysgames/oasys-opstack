// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IBuildSystemConfig } from "src/oasys/L1/build/interfaces/IBuildSystemConfig.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildSystemConfig is IBuildSystemConfig, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildSystemConfig
    function deployBytecode(address payable _messenger) public pure returns (bytes memory) {
        return abi.encodePacked(type(SystemConfig).creationCode, abi.encode(_messenger));
    }
}
