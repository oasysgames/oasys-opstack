// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";

/// @title OasysL1ERC721BridgeLegacySpacer
/// @notice The LegacyOasysStorageLayout_L1ERC721Bridge is a contract that defines the storage layout of Oasys Legacy L1ERC721Bridge.
///         Ref: https://github.com/oasysgames/oasys-optimism/blob/4d667a169296f37422ffaa4901e8d149e84abe5a/packages/contracts/contracts/oasys/L1/messaging/L1ERC721BridgeV2.sol
contract OasysL1ERC721BridgeLegacySpacer {
    /// @custom:legacy
    /// @custom:spacer messenger
    /// @notice Spacer for backwards compatibility.
    address private spacer_0_0_20;

    /// @custom:legacy
    /// @custom:spacer l2ERC721Bridge
    /// @notice Spacer for backwards compatibility.
    address private spacer_1_0_20;

    /// @notice Maps the deposit status of L1 token to L2 token
    ///         This mapping is commonly used in Oasy's L1ERC721Bridge and Optimism's L1ERC721Bridge
    mapping(address => mapping(address => mapping(uint256 => bool))) public deposits;

    /// @notice Reserve extra slots (to a total of 50) in the storage layout for future upgrades.
    ///         A gap size of 47 was chosen here, so that the first slot used in a child contract
    ///         would be a multiple of 50.
    uint256[47] private __gap;
}
