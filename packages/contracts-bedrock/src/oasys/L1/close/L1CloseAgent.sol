// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { L1ChugSplashProxy } from "src/legacy/L1ChugSplashProxy.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";
import { SystemConfigOwnerResolver } from "src/oasys/L1/close/SystemConfigOwnerResolver.sol";
import { ClosedOptimismPortal } from "src/oasys/L1/close/ClosedOptimismPortal.sol";

/// @title L1CloseAgent
/// @notice This contract handles the closing/shutdown of Verse chains that were previously built by L1BuildAgent.
contract L1CloseAgent is ISemver, SystemConfigOwnerResolver {
    /// @notice Implementation address for the closed L1StandardBridge
    address public immutable CLOSED_L1_STANDARD_BRIDGE;

    /// @notice Implementation address for the closed L1ERC721Bridge
    address public immutable CLOSED_L1_ERC721_BRIDGE;

    /// @notice Implementation address for the closed L1CrossDomainMessenger
    address public immutable CLOSED_L1_CROSS_DOMAIN_MESSENGER;

    /// @notice Implementation address for the closed OptimismPortal
    address public immutable CLOSED_OPTIMISM_PORTAL;

    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @notice Constructor sets references to build agents and closed bridge implementations
    /// @param _l1buildAgent Reference to current build agent that created the chains this contract will close
    /// @param _closedL1StandardBridge Implementation address for the closed L1StandardBridge
    /// @param _closedL1ERC721Bridge Implementation address for the closed L1ERC721Bridge
    /// @param _closedL1CrossDomainMessenger Implementation address for the closed L1CrossDomainMessenger
    constructor(
        IL1BuildAgent _l1buildAgent,
        address _closedL1StandardBridge,
        address _closedL1ERC721Bridge,
        address _closedL1CrossDomainMessenger,
        address _closedOptimismPortal
    )
        SystemConfigOwnerResolver(_l1buildAgent)
    {
        CLOSED_L1_STANDARD_BRIDGE = _closedL1StandardBridge;
        CLOSED_L1_ERC721_BRIDGE = _closedL1ERC721Bridge;
        CLOSED_L1_CROSS_DOMAIN_MESSENGER = _closedL1CrossDomainMessenger;
        CLOSED_OPTIMISM_PORTAL = _closedOptimismPortal;
    }

    /// @notice Closes a Verse chain by upgrading bridges to closed implementations and pausing the portal
    /// @param _chainId The chainId of the Verse to close
    function close(uint256 _chainId) public {
        // Only the final system owner can close the chain
        address finalSystemOwner = getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        // Validate the chain id
        (
            address _proxyAdmin,
            ,
            address l1StandardBridgeProxy,
            address l1ERC721BridgeProxy,
            address l1CrossDomainMessengerProxy,
            ,
            address oasysPortalProxy,
            ,
        ) = L1_BUILD_AGENT.builtLists(_chainId);

        // Make sure this contract is the proxy admin owner
        ProxyAdmin proxyAdmin = ProxyAdmin(_proxyAdmin);
        require(proxyAdmin.owner() == address(this), "not transferred admin");

        // Upgrade Bridges to closed implementations
        // - Suspend L1 -> L2 messaging
        // - Handle asset(ERC20,721) withdrawal
        proxyAdmin.upgrade(payable(l1StandardBridgeProxy), CLOSED_L1_STANDARD_BRIDGE);
        proxyAdmin.upgrade(payable(l1ERC721BridgeProxy), CLOSED_L1_ERC721_BRIDGE);

        // Upgrade L1CrossDomainMessenger to closed implementation
        proxyAdmin.upgrade(payable(l1CrossDomainMessengerProxy), CLOSED_L1_CROSS_DOMAIN_MESSENGER);

        // Upgrade portal proxy to closed implementation
        // - Pause L2 -> L1 messaging
        // - Stop deposits(ERC20, ETH)
        proxyAdmin.upgrade(payable(oasysPortalProxy), CLOSED_OPTIMISM_PORTAL);
        ClosedOptimismPortal portal = ClosedOptimismPortal(payable(oasysPortalProxy));
        portal.pause(_chainId);

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
        (address _proxyAdmin,,,,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);

        // Make sure this contract is the proxy admin owner
        ProxyAdmin proxyAdmin = ProxyAdmin(_proxyAdmin);
        require(proxyAdmin.owner() == address(this), "not transferred admin");

        // Transfer back the ownership to the final system owner
        proxyAdmin.transferOwnership(finalSystemOwner);
    }

    /// @notice Retrieves the final system owner and built addresses for a given chain
    /// @param _chainId The chainId of the Verse
    /// @return The final system owner address
    function getOwnerFromSystemConfig(uint256 _chainId) public view returns (address) {
        return _getOwnerFromSystemConfig(_chainId);
    }
}
