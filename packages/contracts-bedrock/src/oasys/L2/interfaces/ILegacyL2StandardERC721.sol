// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @custom:legacy
/// @title ILegacyL2StandardERC721
/// @notice The interface of the legacy L2 standard ERC721 token implemented by Oasys.
///         https://github.com/oasysgames/oasys-optimism/blob/4d667a1/packages/contracts/contracts/oasys/L2/token/IL2StandardERC721.sol
interface ILegacyL2StandardERC721 is IERC721 {
    function l1Token() external view returns (address);

    function mint(address _to, uint256 _tokenId) external;

    function burn(address _from, uint256 _tokenId) external;

    event L2BridgeMint(address indexed _account, uint256 _tokenId);
    event L2BridgeBurn(address indexed _account, uint256 _tokenId);
}
