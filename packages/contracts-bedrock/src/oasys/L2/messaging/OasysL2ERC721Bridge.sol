// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
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
    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    /// @dev Ref:
    /// https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L2/messaging/L2ERC721Bridge.sol#L30
    function l1ERC721Bridge() external view returns (address) {
        return address(otherBridge);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    /// @dev Ref:
    /// https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L2/messaging/L2ERC721Bridge.sol#L53-L58
    function withdraw(address _l2Token, uint256 _tokenId, uint32 _l1Gas, bytes calldata _data) external {
        // Copied from ERC721Bridge.bridgeERC721
        // start ----------------------------
        // Modifier requiring sender to be EOA. This prevents against a user error that would occur
        // if the sender is a smart contract wallet that has a different address on the remote chain
        // (or doesn't have an address on the remote chain at all). The user would fail to receive
        // the NFT if they use this function because it sends the NFT to the same address as the
        // caller. This check could be bypassed by a malicious contract via initcode, but it takes
        // care of the user error we want to avoid.
        require(!Address.isContract(msg.sender), "ERC721Bridge: account is not externally owned");
        // ------------------------------ end

        _initiateBridgeERC721(_l2Token, _l2Token, msg.sender, msg.sender, _tokenId, _l1Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    /// @dev Ref:
    /// https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L2/messaging/L2ERC721Bridge.sol#L65-L71
    function withdrawTo(
        address _l2Token,
        address _to,
        uint256 _tokenId,
        uint32 _l1Gas,
        bytes calldata _data
    )
        external
    {
        // Copied from ERC721Bridge.bridgeERC721To
        // start ----------------------------
        require(_to != address(0), "ERC721Bridge: nft recipient cannot be address(0)");
        // ------------------------------ end

        _initiateBridgeERC721(_l2Token, _l2Token, msg.sender, _to, _tokenId, _l1Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL2ERC721Bridge
    /// @dev Ref:
    /// https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L2/messaging/L2ERC721Bridge.sol#L130-L137
    function finalizeDeposit(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
        public
    {
        finalizeBridgeERC721(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    /// @inheritdoc L2ERC721Bridge
    /// @dev override to support legacy L2ERC721Bridge
    function finalizeBridgeERC721(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _extraData
    )
        public
        override
        onlyOtherBridge
    {
        if (_isOptimismMintableToken(_localToken)) {
            // Proceed with the original implementation if the local token is optimism mintable
            super.finalizeBridgeERC721(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
        } else {
            // Following implementation is for legacy L2StandardERC721
            // Mostly copied from the original implementation
            require(_localToken != address(this), "L2ERC721Bridge: local token cannot be self");

            // Note that supportsInterface makes a callback to the _localToken address which is user
            // provided.
            require(
                ERC165Checker.supportsInterface(_localToken, type(ILegacyL2StandardERC721).interfaceId),
                "L2ERC721Bridge: local token interface is not compliant"
            );

            require(
                // Legacy token references the remote token as `l1Token`
                _remoteToken == ILegacyL2StandardERC721(_localToken).l1Token(),
                "L2ERC721Bridge: wrong remote token for Oasys Legacy ERC721 local token"
            );

            // When a deposit is finalized, we give the NFT with the same tokenId to the account
            // on L2. Note that safeMint makes a callback to the _to address which is user provided.
            // Legacy token does not have safeMint, so we use mint instead
            ILegacyL2StandardERC721(_localToken).mint(_to, _tokenId);

            // slither-disable-next-line reentrancy-events
            emit ERC721BridgeFinalized(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
        }

        // Emit Legacy event for backward compatibility
        // slither-disable-next-line reentrancy-events
        emit DepositFinalized(_remoteToken, _localToken, _from, _to, _tokenId, _extraData);
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
        // Keep remote token for the legacy
        address remoteToken;

        if (_isOptimismMintableToken(_localToken)) {
            remoteToken = _remoteToken;

            // Proceed with the original implementation if the local token is optimism mintable
            super._initiateBridgeERC721(_localToken, remoteToken, _from, _to, _tokenId, _minGasLimit, _extraData);
        } else {
            // Following implementation is for legacy L2StandardERC721
            // Mostly copied from the original implementation

            require(_remoteToken != address(0), "L2ERC721Bridge: remote token cannot be address(0)");

            // Check that the withdrawal is being initiated by the NFT owner
            require(
                _from == IERC721(_localToken).ownerOf(_tokenId),
                "L2ERC721Bridge: Withdrawal is not being initiated by NFT owner"
            );

            // Construct calldata for l1ERC721Bridge.finalizeBridgeERC721(_to, _tokenId)
            // Legacy token references the remote token as `l1Token`
            // slither-disable-next-line reentrancy-events
            remoteToken = ILegacyL2StandardERC721(_localToken).l1Token();
            // Skip the following check because the legacy interfaces (withdraw, withdrawTo) do not specify the correct
            // remote token,
            // resulting in failures.
            // require(remoteToken == _remoteToken, "L2ERC721Bridge: remote token does not match given value");

            // When a withdrawal is initiated, we burn the withdrawer's NFT to prevent subsequent L2
            // usage
            // slither-disable-next-line reentrancy-events
            ILegacyL2StandardERC721(_localToken).burn(_from, _tokenId);

            bytes memory message = abi.encodeWithSelector(
                L1ERC721Bridge.finalizeBridgeERC721.selector, remoteToken, _localToken, _from, _to, _tokenId, _extraData
            );

            // Send message to L1 bridge
            // slither-disable-next-line reentrancy-events
            messenger.sendMessage(address(otherBridge), message, _minGasLimit);

            // slither-disable-next-line reentrancy-events
            emit ERC721BridgeInitiated(_localToken, remoteToken, _from, _to, _tokenId, _extraData);
        }

        // Emit Legacy event for backward compatibility
        // slither-disable-next-line reentrancy-events
        emit WithdrawalInitiated(remoteToken, _localToken, _from, _to, _tokenId, _extraData);
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
}
