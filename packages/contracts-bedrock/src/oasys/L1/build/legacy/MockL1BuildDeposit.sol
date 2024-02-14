// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IL1BuildDeposit } from "../interfaces/IL1BuildDeposit.sol";

contract MockL1BuildDeposit is IL1BuildDeposit {
    uint256 public requiredAmount;
    mapping(address => uint256) private _depositTotal;

    constructor(uint256 _requiredAmount) {
        requiredAmount = _requiredAmount;
    }

    function deposit(address _builder) external payable {
        _depositTotal[_builder] += msg.value;
    }

    function getDepositTotal(address _builder) external view returns (uint256) {
        return _depositTotal[_builder];
    }
}
