// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { ILegacyL1ERC721Bridge } from "src/oasys/L1/interfaces/ILegacyL1ERC721Bridge.sol";

/// @title OasysL1ERC721Bridge
/// @notice The OasysL1ERC721Bridge is a contract that adds compatibility with
///         the legacy L1ERC721Bridge implemented by Oasys to the official Optimism L1ERC721Bridge.
contract OasysL1ERC721Bridge is L1ERC721Bridge, ILegacyL1ERC721Bridge {
    /// @notice Constructs the OasysL1ERC721Bridge contract.
    /// @param _messenger   Address of the CrossDomainMessenger on this network.
    /// @param _otherBridge Address of the ERC721 bridge on the other network.
    constructor(address _messenger, address _otherBridge) L1ERC721Bridge(_messenger, _otherBridge) { }

    /// @custom:legacy
    /// @inheritdoc ILegacyL1ERC721Bridge
    function l2ERC721Bridge() external view returns (address) {
        return OTHER_BRIDGE;
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL1ERC721Bridge
    function depositERC721(
        address _l1Token,
        address _l2Token,
        uint256 _tokenId,
        uint32 _l2Gas,
        bytes calldata _data
    )
        external
    {
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

        _initiateBridgeERC721(_l1Token, _l2Token, msg.sender, msg.sender, _tokenId, _l2Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL1ERC721Bridge
    function depositERC721To(
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _tokenId,
        uint32 _l2Gas,
        bytes calldata _data
    )
        external
    {
        // Copied from ERC721Bridge.bridgeERC721To
        // start ----------------------------
        require(_to != address(0), "ERC721Bridge: nft recipient cannot be address(0)");
        // ------------------------------ end

        _initiateBridgeERC721(_l1Token, _l2Token, msg.sender, _to, _tokenId, _l2Gas, _data);
    }

    /// @custom:legacy
    /// @inheritdoc ILegacyL1ERC721Bridge
    function finalizeERC721Withdrawal(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
        external
    {
        finalizeBridgeERC721(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    /// @inheritdoc L1ERC721Bridge
    /// @dev Emits an legacy ERC721WithdrawalFinalized event for backwards compatibility.
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
    {
        super.finalizeBridgeERC721(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);

        // Ref:
        // https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L1/messaging/IL1ERC721Bridge.sol#L21-L28
        // slither-disable-next-line reentrancy-events
        emit ERC721WithdrawalFinalized(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
    }

    /// @inheritdoc L1ERC721Bridge
    /// @dev Emits an legacy ERC721DepositInitiated event for backwards compatibility.
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
        super._initiateBridgeERC721(_localToken, _remoteToken, _from, _to, _tokenId, _minGasLimit, _extraData);

        // Ref:
        // https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L1/messaging/IL1ERC721Bridge.sol#L12-L19
        // slither-disable-next-line reentrancy-events
        emit ERC721DepositInitiated(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
    }
}
