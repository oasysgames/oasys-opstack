// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuildOasysL1ERC721Bridge {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _messenger   Address of the CrossDomainMessenger on this network.
    /// @param _otherBridge Address of the ERC721 bridge on the other network.
    function deployBytecode(address _messenger, address _otherBridge) external pure returns (bytes memory);
}
