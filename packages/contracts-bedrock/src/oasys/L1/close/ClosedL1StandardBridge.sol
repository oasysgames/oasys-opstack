// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";

/// @title ClosedL1StandardBridge
/// @notice L1 standard bridge in a "closed" state.
contract ClosedL1StandardBridge is L1StandardBridge {
    /// @notice Reference to the L1 build agent used to resolve system config and built addresses per chain.
    IL1BuildAgent public immutable L1_BUILD_AGENT;

    /// @param _l1buildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1buildAgent) {
        L1_BUILD_AGENT = _l1buildAgent;
    }

    /// @notice Withdraws ERC20 tokens held by this bridge to a specified address.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    /// @param _erc20 ERC20 contract address.
    /// @param _to Recipient of the tokens.
    /// @param _amount Amount to transfer.
    function withdrawERC20(uint256 _chainId, address _erc20, address _to, uint256 _amount) external virtual {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        (,,,,, address l1StandardBridgeProxy,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        require(l1StandardBridgeProxy == address(this), "not the bridge");

        require(IERC20(_erc20).balanceOf(address(this)) >= _amount, "not enough balance");
        IERC20(_erc20).transfer(_to, _amount);
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

    /// @notice Returns the final system owner and built address list for a chain.
    /// @param _chainId Chain ID to look up.
    /// @return Final system owner address
    function _getOwnerFromSystemConfig(uint256 _chainId) internal view returns (address) {
        // Validate the chain id
        (,,, address systemConfigPorxy,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(systemConfigPorxy != address(0), "invalid chain id");

        // Get the owner as well as the build list
        SystemConfig systemConfig = SystemConfig(systemConfigPorxy);
        return systemConfig.owner();
    }
}
