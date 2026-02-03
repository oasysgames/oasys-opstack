// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { SystemConfigOwnerResolver } from "src/oasys/L1/close/SystemConfigOwnerResolver.sol";

/// @title ClosedL1ERC721Bridge
/// @notice L1 ERC721 bridge in a "closed" state.
contract ClosedL1ERC721Bridge is OasysL1ERC721Bridge, SystemConfigOwnerResolver {
    /// @param _l1buildAgent L1 build agent for chain config and built address lookup.
    constructor(IL1BuildAgent _l1buildAgent) SystemConfigOwnerResolver(_l1buildAgent) { }

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
        onlyFinalSystemOwner(_chainId)
    {
        (,,, address l1ERC721BridgeProxy,,,,,) = L1_BUILD_AGENT.builtLists(_chainId);
        require(l1ERC721BridgeProxy == address(this), "not the bridge");

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
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
}
