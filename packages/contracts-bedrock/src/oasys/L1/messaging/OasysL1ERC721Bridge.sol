// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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
        onlyEOA
    {
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
        require(_to != address(0), "L1ERC721Bridge: nft recipient cannot be address(0)");

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
        this.finalizeBridgeERC721(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    /// @inheritdoc L1ERC721Bridge
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

        // slither-disable-next-line reentrancy-events
        emit ERC721WithdrawalFinalized(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
    }

    /// @inheritdoc L1ERC721Bridge
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

        // slither-disable-next-line reentrancy-events
        emit ERC721DepositInitiated(_localToken, _remoteToken, _from, _to, _tokenId, _extraData);
    }
}
