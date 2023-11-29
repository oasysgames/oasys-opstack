// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuildL1CrossDomainMessenger {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _portal Address of the OptimismPortal contract on this network.
    function deployBytecode(address payable _portal) external pure returns (bytes memory);

    /// @notice Return data for initializer.
    function initializeData() external pure returns (bytes memory);
}
