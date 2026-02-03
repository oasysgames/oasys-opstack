// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { SystemConfigOwnerResolver } from "src/oasys/L1/close/SystemConfigOwnerResolver.sol";

/// @title ClosedOptimismPortal
/// @notice OptimismPortal in a "closed" state. Only the final system owner can pause/unpause.
contract ClosedOptimismPortal is OptimismPortal, SystemConfigOwnerResolver {
    /// @notice Closed-layer pause flag. When true, withdrawals are blocked regardless of SuperchainConfig.
    bool private _closedPaused;

    /// @param _l1buildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1buildAgent) SystemConfigOwnerResolver(_l1buildAgent) { }

    /// @notice Transfers all native ETH held by this portal to a specified address.
    /// @dev During close, all ETH is transferred to the final system owner.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    /// @param _to Recipient of the ETH.
    function transferAllETH(uint256 _chainId, address _to) external virtual {
        (,,,,,, address portalProxy,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(portalProxy == address(this), "not the portal");
        (bool success,) = payable(_to).call{ value: address(this).balance }("");
        require(success, "transfer failed");
    }

    /// @notice Returns whether the portal is paused (closed layer or superchain).
    function paused() public view override returns (bool) {
        return _closedPaused || super.paused();
    }

    /// @notice Pauses the portal. Only the final system owner or the ProxyAdmin owner (e.g. L1CloseAgent during close)
    /// may call.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    function pause(uint256 _chainId) external virtual {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        (address proxyAdmin,,,,,, address portalProxy,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(portalProxy == address(this), "not the portal");
        require(
            finalSystemOwner == msg.sender || ProxyAdmin(proxyAdmin).owner() == msg.sender, "not final system owner"
        );

        _closedPaused = true;
    }

    /// @notice Unpauses the portal. Only the final system owner or the ProxyAdmin owner may call.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    function unpause(uint256 _chainId) external virtual {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        (address proxyAdmin,,,,,, address portalProxy,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(portalProxy == address(this), "not the portal");
        require(
            finalSystemOwner == msg.sender || ProxyAdmin(proxyAdmin).owner() == msg.sender, "not final system owner"
        );

        _closedPaused = false;
    }

    /// @notice Reverts. The portal is closed; deposits are disabled.
    receive() external payable override {
        revert("portal is closed");
    }

    /// @notice Reverts. The portal is closed; deposits are disabled.
    function depositERC20Transaction(
        address, /*_to*/
        uint256, /*_mint*/
        uint256, /*_value*/
        uint64, /*_gasLimit*/
        bool, /*_isCreation*/
        bytes memory /*_data*/
    )
        public
        virtual
        override
    {
        revert("portal is closed");
    }

    /// @notice Reverts. The portal is closed; deposits are disabled.
    function depositTransaction(address, uint256, uint64, bool, bytes memory) public payable virtual override {
        revert("portal is closed");
    }
}
