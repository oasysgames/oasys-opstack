// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { IBuildL1CrossDomainMessenger } from "src/oasys/L1/build/interfaces/IBuildL1CrossDomainMessenger.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL1CrossDomainMessenger is IBuildL1CrossDomainMessenger, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildL1CrossDomainMessenger
    function deployBytecode(address payable _portal) public pure returns (bytes memory) {
        return abi.encodePacked(type(L1CrossDomainMessenger).creationCode, abi.encode(_portal));
    }

    /// @notice Return data for initializer.
    function initializeData() external pure returns (bytes memory) {
        return abi.encodeCall(L1CrossDomainMessenger.initialize, ());
    }
}
