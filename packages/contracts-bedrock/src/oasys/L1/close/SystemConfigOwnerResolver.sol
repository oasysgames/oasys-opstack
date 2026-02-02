// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";

/// @title SystemConfigOwnerResolver
/// @notice Base contract that resolves the final system owner from SystemConfig via L1BuildAgent.
abstract contract SystemConfigOwnerResolver {
    /// @notice Reference to the L1 build agent used to resolve system config per chain.
    IL1BuildAgent public immutable L1_BUILD_AGENT;

    /// @param _l1BuildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1BuildAgent) {
        L1_BUILD_AGENT = _l1BuildAgent;
    }

    /// @notice Returns the final system owner for a chain from its SystemConfig.
    /// @param _chainId Chain ID to look up.
    /// @return Final system owner address.
    function _getOwnerFromSystemConfig(uint256 _chainId) internal view returns (address) {
        (, address systemConfigProxy,,,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(systemConfigProxy != address(0), "invalid chain id");

        SystemConfig systemConfig = SystemConfig(systemConfigProxy);
        return systemConfig.owner();
    }
}
