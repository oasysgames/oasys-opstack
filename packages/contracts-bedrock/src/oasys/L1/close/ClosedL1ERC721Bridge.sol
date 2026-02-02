// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";

/// @title ClosedL1ERC721Bridge
/// @notice L1 ERC721 bridge in a "closed" state.
contract ClosedL1ERC721Bridge is OasysL1ERC721Bridge {
    /// @notice Reference to the L1 build agent used to resolve system config and built addresses per chain.
    IL1BuildAgent public immutable L1_BUILD_AGENT;

    /// @param _l1buildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1buildAgent) {
        L1_BUILD_AGENT = _l1buildAgent;
    }

    /// @notice Withdraws ERC721 tokens held by this bridge to a specified address.
    /// @param _chainId Chain ID used to resolve system config and final system owner.
    /// @param _erc721 ERC721 contract address.
    /// @param _to Recipient of the tokens.
    /// @param _tokenIds Token IDs to transfer.
    function withdrawERC721(
        uint256 _chainId,
        address _erc721,
        address _to,
        uint256[] calldata _tokenIds
    )
        external
        virtual
    {
        address finalSystemOwner = _getOwnerFromSystemConfig(_chainId);
        require(finalSystemOwner == msg.sender, "not final system owner");
        (,,,,,, address l1ERC721BridgeProxy,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(l1ERC721BridgeProxy == address(this), "not the bridge");

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            require(IERC721(_erc721).ownerOf(_tokenIds[i]) == address(this), "not owned by bridge");
            IERC721(_erc721).safeTransferFrom(address(this), _to, _tokenIds[i]);
        }
    }

    /// @notice Reverts. The bridge is closed; ERC721 bridging is disabled.
    function _initiateBridgeERC721(
        address, /*_localToken*/
        address, /*_remoteToken*/
        address, /*_from*/
        address, /*_to*/
        uint256, /*_tokenId*/
        uint32, /*_minGasLimit*/
        bytes calldata /*_extraData*/
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
