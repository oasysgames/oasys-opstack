// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuildL1StandardBridge {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _messenger Address of the L1CrossDomainMessenger.
    function deployBytecode(address payable _messenger) external pure returns (bytes memory);
}
