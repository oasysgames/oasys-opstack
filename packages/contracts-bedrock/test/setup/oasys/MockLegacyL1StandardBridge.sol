// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockLegacyL1StandardBridge {
    address public messenger;
    address public l2TokenBridge;
    mapping(address => mapping(address => uint256)) public deposits;
    function depositETH(uint32 /*_l2Gas*/, bytes calldata /*_data*/) external payable {}
    function depositERC20(
        address _l1Token,
        address _l2Token,
        uint256 _amount,
        uint32 /*_l2Gas*/,
        bytes calldata /*_data*/
    ) external {
        deposits[_l1Token][_l2Token] = deposits[_l1Token][_l2Token] + _amount;
        IERC20(_l1Token).transferFrom(msg.sender, address(this), _amount);
    }
}