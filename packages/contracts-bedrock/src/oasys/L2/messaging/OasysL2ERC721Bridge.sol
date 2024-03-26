// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { L2ERC721Bridge } from "src/L2/L2ERC721Bridge.sol";
import { ILegacyL2ERC721Bridge } from "src/oasys/L2/interfaces/ILegacyL2ERC721Bridge.sol";
import { ILegacyL2StandardERC721 } from "src/oasys/L2/interfaces/ILegacyL2StandardERC721.sol";
import { IOptimismMintableERC721 } from "src/universal/IOptimismMintableERC721.sol";

/// @title OasysL2ERC721Bridge
/// @notice The OasysL2ERC721Bridge is a contract that adds compatibility with
///         the legacy L2ERC721Bridge implemented by Oasys to the official Optimism L2ERC721Bridge.
///         This bridge supports OptimismMintableERC721 and legacy L2StandardERC721.
contract OasysL2ERC721Bridge is L2ERC721Bridge, ILegacyL2ERC721Bridge {
    /// @notice Constructs the OasysL2ERC721Bridge contract.
    /// @param _messenger   Address of the CrossDomainMessenger on this network.
    /// @param _otherBridge Address of the ERC721 bridge on the other network.
    constructor(address _messenger, address _otherBridge) L2ERC721Bridge(_messenger, _otherBridge) { }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    function l1ERC721Bridge() external view returns (address) {
        return OTHER_BRIDGE;
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    function withdraw(address _l2Token, uint256 _tokenId, uint32 _l1Gas, bytes calldata _data) external onlyEOA {
        _initiateBridgeERC721(_l2Token, _getRemoteToken(_l2Token), msg.sender, msg.sender, _tokenId, _l1Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    function withdrawTo(
        address _l2Token,
        address _to,
        uint256 _tokenId,
        uint32 _l1Gas,
        bytes calldata _data
    )
        external
    {
        require(_to != address(0), "L2ERC721Bridge: nft recipient cannot be address(0)");

        _initiateBridgeERC721(_l2Token, _getRemoteToken(_l2Token), msg.sender, _to, _tokenId, _l1Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    function finalizeDeposit(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
        external
        onlyOtherBridge
    {
        _finalizeBridgeERC721(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    /// @inheritdoc L2ERC721Bridge
    function finalizeBridgeERC721(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _extraData
    )
        external
        override
        onlyOtherBridge
    {
        _finalizeBridgeERC721(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
    }

    /// @inheritdoc L2ERC721Bridge
    function _initiateBridgeERC721(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _tokenId,
        uint32 _minGasLimit,
        bytes calldata _extraData
    )
        internal
        override
    {
        require(_remoteToken != address(0), "L2ERC721Bridge: remote token cannot be address(0)");
        require(_remoteToken == _getRemoteToken(_localToken), "L2ERC721Bridge: remote token does not match given value");

        // Check that the withdrawal is being initiated by the NFT owner
        require(
            _from == IERC721(_localToken).ownerOf(_tokenId),
            "L2ERC721Bridge: Withdrawal is not being initiated by NFT owner"
        );

        // Construct calldata for l1ERC721Bridge.finalizeBridgeERC721(_to, _tokenId)
        // When a withdrawal is initiated, we burn the withdrawer's NFT to prevent subsequent L2 usage
        // slither-disable-next-line reentrancy-events
        _burnLocalToken(_localToken, _from, _tokenId);

        bytes memory message = abi.encodeWithSelector(
            L1ERC721Bridge.finalizeBridgeERC721.selector, _remoteToken, _localToken, _from, _to, _tokenId, _extraData
        );

        // Send message to L1 bridge
        // slither-disable-next-line reentrancy-events
        MESSENGER.sendMessage(OTHER_BRIDGE, message, _minGasLimit);

        // slither-disable-next-line reentrancy-events
        emit ERC721BridgeInitiated(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
        // slither-disable-next-line reentrancy-events
        emit WithdrawalInitiated(_remoteToken, _localToken, _from, _to, _tokenId, _extraData);
    }

    /// @notice Completes an ERC721 bridge from the other domain and sends the ERC721 token to the
    ///         recipient on this domain.
    /// @param _localToken  Address of the ERC721 token on this domain.
    /// @param _remoteToken Address of the ERC721 token on the other domain.
    /// @param _from        Address that triggered the bridge on the other domain.
    /// @param _to          Address to receive the token on this domain.
    /// @param _tokenId     ID of the token being deposited.
    /// @param _extraData   Optional data to forward to L1.
    ///                     Data supplied here will not be used to execute any code on L1 and is
    ///                     only emitted as extra data for the convenience of off-chain tooling.
    function _finalizeBridgeERC721(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _extraData
    )
        internal
    {
        require(_localToken != address(this), "L2ERC721Bridge: local token cannot be self");
        require(_remoteToken == _getRemoteToken(_localToken), "L2ERC721Bridge: remote token does not match given value");

        // When a deposit is finalized, we give the NFT with the same tokenId to the account
        // on L2. Note that safeMint makes a callback to the _to address which is user provided.
        _mintLocalToken(_localToken, _to, _tokenId);

        // slither-disable-next-line reentrancy-events
        emit ERC721BridgeFinalized(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
        // slither-disable-next-line reentrancy-events
        emit DepositFinalized(_remoteToken, _localToken, _from, _to, _tokenId, _extraData);
    }

    /// @notice Determine if the local token is an ILegacyL2StandardERC721.
    /// @param _localToken Address of the local token.
    /// @return true if the local token is an ILegacyL2StandardERC721.
    function _isLegacyStandardToken(address _localToken) internal view returns (bool) {
        return ERC165Checker.supportsInterface(_localToken, type(ILegacyL2StandardERC721).interfaceId);
    }

    /// @notice Determine if the local token is an IOptimismMintableERC721.
    /// @param _localToken Address of the local token.
    /// @return true if the local token is an IOptimismMintableERC721.
    function _isOptimismMintableToken(address _localToken) internal view returns (bool) {
        return ERC165Checker.supportsInterface(_localToken, type(IOptimismMintableERC721).interfaceId);
    }

    /// @notice Returns the address of the remote token that is paired with the local token.
    ///         Note: Will revert if the local token is not ILegacyL2StandardERC721 or OptimismMintableERC721.
    /// @param _localToken Address of the local token.
    /// @return Address of the remote token.
    function _getRemoteToken(address _localToken) internal view returns (address) {
        if (_isLegacyStandardToken(_localToken)) {
            return ILegacyL2StandardERC721(_localToken).l1Token();
        } else if (_isOptimismMintableToken(_localToken)) {
            return IOptimismMintableERC721(_localToken).remoteToken();
        } else {
            revert("L2ERC721Bridge: local token interface is not compliant");
        }
    }

    /// @notice Mints some token ID for a user, checking first that contract recipients
    ///         are aware of the ERC721 protocol to prevent tokens from being forever locked.
    /// @param _localToken Address of the local token.
    /// @param _to         Address of the user to mint the token for.
    /// @param _tokenId    Token ID to mint.
    function _mintLocalToken(address _localToken, address _to, uint256 _tokenId) internal {
        if (_isLegacyStandardToken(_localToken)) {
            ILegacyL2StandardERC721(_localToken).mint(_to, _tokenId);
        } else if (_isOptimismMintableToken(_localToken)) {
            IOptimismMintableERC721(_localToken).safeMint(_to, _tokenId);
        } else {
            revert("L2ERC721Bridge: local token interface is not compliant");
        }
    }

    /// @notice Burns a token ID from a user.
    /// @param _localToken Address of the local token.
    /// @param _from       Address of the user to burn the token from.
    /// @param _tokenId    Token ID to burn.
    function _burnLocalToken(address _localToken, address _from, uint256 _tokenId) internal {
        if (_isLegacyStandardToken(_localToken)) {
            ILegacyL2StandardERC721(_localToken).burn(_from, _tokenId);
        } else if (_isOptimismMintableToken(_localToken)) {
            IOptimismMintableERC721(_localToken).burn(_from, _tokenId);
        } else {
            revert("L2ERC721Bridge: local token interface is not compliant");
        }
    }
}
