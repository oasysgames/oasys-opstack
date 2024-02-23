// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IL1BuildDeposit {
    function requiredAmount() external view returns (uint256);

    function getDepositTotal(address _builder) external view returns (uint256);

    function build(address _builder) external;

    function deposit(address _builder) external payable;

    function withdraw(address _builder, uint256 _amount) external;
}
