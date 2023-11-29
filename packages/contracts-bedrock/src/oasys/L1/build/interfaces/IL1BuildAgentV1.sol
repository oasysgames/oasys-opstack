// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IL1BuildAgentV1 {
    function getAddressManager(uint256 _chainId) external view returns (address);
}
