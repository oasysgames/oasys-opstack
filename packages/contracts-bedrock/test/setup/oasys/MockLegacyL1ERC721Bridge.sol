// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MockLegacyL1ERC721Bridge {
    address public messenger;
    address public l2ERC721Bridge;
    mapping(address => mapping(address => mapping(uint256 => bool))) public deposits;
    function depositERC721(
        address _l1Token,
        address _l2Token,
        uint256 _tokenId,
        uint32 /*_l2Gas*/,
        bytes calldata /*_data*/
    ) external {
        deposits[_l1Token][_l2Token][_tokenId] = true;
        IERC721(_l1Token).transferFrom(msg.sender, address(this), _tokenId);
    }
}