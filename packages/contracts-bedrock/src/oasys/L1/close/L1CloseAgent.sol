// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { L1ChugSplashProxy } from "src/legacy/L1ChugSplashProxy.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";

interface ILegacyOptimismPortal {
    function GUARDIAN() external view returns (address);
    function pause() external;
    function unpause() external;
}

/// @title L1CloseAgent
/// @notice This contract handles the closing/shutdown of Verse chains that were previously built by L1BuildAgent.
contract L1CloseAgent is ISemver {
    /// @notice Reference to the legacy L1BuildAgent (V1)
    ILegacyL1BuildAgent public immutable LEGACY_L1_BUILD_AGENT;

    /// @notice Reference to the current L1BuildAgent (V2)
    IL1BuildAgent public immutable L1_BUILD_AGENT;

    /// @notice Implementation address for the closed L1StandardBridge
    address public immutable CLOSED_L1_STANDARD_BRIDGE;

    /// @notice Implementation address for the closed L1ERC721Bridge
    address public immutable CLOSED_L1_ERC721_BRIDGE;

    /// @notice Implementation address for the closed L1CrossDomainMessenger
    address public immutable CLOSED_L1_CROSS_DOMAIN_MESSENGER;

    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @notice Constructor sets references to build agents and closed bridge implementations
    /// @param _legacyL1BuildAgent Reference to legacy build agent (same as L1BuildAgent.LEGACY_L1_BUILD_AGENT)
    /// @param _l1buildAgent Reference to current build agent that created the chains this contract will close
    /// @param _closedL1StandardBridge Implementation address for the closed L1StandardBridge
    /// @param _closedL1ERC721Bridge Implementation address for the closed L1ERC721Bridge
    /// @param _closedL1CrossDomainMessenger Implementation address for the closed L1CrossDomainMessenger
    constructor(
        ILegacyL1BuildAgent _legacyL1BuildAgent,
        IL1BuildAgent _l1buildAgent,
        address _closedL1StandardBridge,
        address _closedL1ERC721Bridge,
        address _closedL1CrossDomainMessenger
    ) {
        LEGACY_L1_BUILD_AGENT = _legacyL1BuildAgent;
        L1_BUILD_AGENT = _l1buildAgent;
        CLOSED_L1_STANDARD_BRIDGE = _closedL1StandardBridge;
        CLOSED_L1_ERC721_BRIDGE = _closedL1ERC721Bridge;
        CLOSED_L1_CROSS_DOMAIN_MESSENGER = _closedL1CrossDomainMessenger;
    }

    /// @notice Closes a Verse chain by upgrading bridges to closed implementations and pausing the portal
    /// @param _chainId The chainId of the Verse to close
    function close(uint256 _chainId) public {
        // Only the final system owner can close the chain
        address finalSystemOwner = getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        // Validate the chain id
        (
            address proxyAdminAddr,
            address oasysPortalProxy,
            ,
            ,
            address l1CrossDomainMessengerProxy,
            address l1StandardBridgeProxy,
            address l1ERC721BridgeProxy,
            ,
        ) = L1_BUILD_AGENT.builtLists(_chainId);

        // Make sure this contract is the proxy admin owner
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddr);
        require(proxyAdmin.owner() == address(this), "not transferred admin");

        // Upgrade Bridges to closed implementations
        // - Suspend L1 -> L2 messaging
        // - Handle asset(ERC20,721) withdrawal
        proxyAdmin.upgrade(payable(l1StandardBridgeProxy), CLOSED_L1_STANDARD_BRIDGE);
        proxyAdmin.upgrade(payable(l1ERC721BridgeProxy), CLOSED_L1_ERC721_BRIDGE);

        // Pause L2 -> L1 messaging
        ILegacyOptimismPortal portal = ILegacyOptimismPortal(payable(oasysPortalProxy));
        require(portal.GUARDIAN() == msg.sender, "not portal guardian");
        portal.pause();

        // Upgrade L1CrossDomainMessenger to closed implementation
        proxyAdmin.upgrade(payable(l1CrossDomainMessengerProxy), CLOSED_L1_CROSS_DOMAIN_MESSENGER);

        // NOTE: About L2OutputOracle
        // Don't stop L2 root submission, because challenger key can delete unintended L2 roots.

        // Give back proxy admin ownership to the original owner
        proxyAdmin.transferOwnership(finalSystemOwner);
    }

    /// @notice Transfers ProxyAdmin ownership back to the final system owner without closing the chain
    /// @param _chainId The chainId of the Verse
    function transferProxyAdminOwnership(uint256 _chainId) public {
        // Only the final system owner can transfer proxy admin ownership
        address finalSystemOwner = getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        (address proxyAdminAddr,,,,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);

        // Make sure this contract is the proxy admin owner
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddr);
        require(proxyAdmin.owner() == address(this), "not transferred admin");

        // Transfer back the ownership to the final system owner
        proxyAdmin.transferOwnership(finalSystemOwner);
    }

    /// @notice Retrieves the final system owner and built addresses for a given chain
    /// @param _chainId The chainId of the Verse
    /// @return The final system owner address
    function getOwnerFromSystemConfig(uint256 _chainId) public view returns (address) {
        // Validate the chain id
        (,,, address systemConfigPorxy,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(systemConfigPorxy != address(0), "invalid chain id");

        // Get the owner as well as the build list
        SystemConfig systemConfig = SystemConfig(systemConfigPorxy);
        return systemConfig.owner();
    }

    /// @notice Check if the L2 is a legacy L2 built by the V1 build agent
    /// @param _chainId The chainId of Verse
    /// @return bool indicating if this is a legacy L2, and the AddressManager address if it exists
    function _isLegacyL2(uint256 _chainId) internal view returns (bool, address) {
        // If AddressManager exists, it's legacy
        address addressManager = LEGACY_L1_BUILD_AGENT.getAddressManager(_chainId);
        return (addressManager != address(0), addressManager);
    }
}
