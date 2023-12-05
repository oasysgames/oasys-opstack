// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ILegacyL1BuildAgent {
    function getAddressManager(uint256 _chainId) external view returns (address);
}
