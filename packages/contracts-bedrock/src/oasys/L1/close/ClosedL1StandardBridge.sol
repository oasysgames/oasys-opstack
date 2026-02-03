// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { SystemConfigOwnerResolver } from "src/oasys/L1/close/SystemConfigOwnerResolver.sol";

/// @title ClosedL1StandardBridge
/// @notice L1 standard bridge in a "closed" state.
contract ClosedL1StandardBridge is L1StandardBridge, SystemConfigOwnerResolver {
    using SafeERC20 for IERC20;

    /// @param _l1buildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1buildAgent) SystemConfigOwnerResolver(_l1buildAgent) { }

    /// @notice Withdraws ERC20 tokens held by this bridge to a specified address.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    /// @param _erc20 ERC20 contract address.
    /// @param _to Recipient of the tokens.
    /// @param _amount Amount to transfer.
    function withdrawERC20(uint256 _chainId, address _erc20, address _to, uint256 _amount) external virtual {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        (,, address l1StandardBridgeProxy,,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(l1StandardBridgeProxy == address(this), "not the bridge");

        IERC20(_erc20).safeTransfer(_to, _amount);
    }

    /// @notice Withdraws native ETH held by this bridge to a specified address.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    /// @param _to Recipient of the ETH.
    /// @param _amount Amount to transfer.
    function withdrawETH(uint256 _chainId, address _to, uint256 _amount) external virtual {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        (,, address l1StandardBridgeProxy,,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(l1StandardBridgeProxy == address(this), "not the bridge");
        require(address(this).balance >= _amount, "not enough balance");

        (bool success,) = payable(_to).call{ value: _amount }("");
        require(success, "transfer failed");
    }

    /// @notice Reverts. The bridge is closed; ETH bridging is disabled.
    function _initiateBridgeETH(
        address, /*_from*/
        address, /*_to*/
        uint256, /*_amount*/
        uint32, /*_minGasLimit*/
        bytes memory /*_extraData*/
    )
        internal
        virtual
        override
    {
        revert("bridge is closed");
    }

    /// @notice Reverts. The bridge is closed; ERC20 bridging is disabled.
    function _initiateBridgeERC20(
        address, /*_localToken*/
        address, /*_remoteToken*/
        address, /*_from*/
        address, /*_to*/
        uint256, /*_amount*/
        uint32, /*_minGasLimit*/
        bytes memory /*_extraData*/
    )
        internal
        virtual
        override
    {
        revert("bridge is closed");
    }
}
