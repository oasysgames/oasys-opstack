// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { StorageSetter } from "src/universal/StorageSetter.sol";

/// @title IUpgradeManager
/// @notice Interface for managing L2 upgrades across multiple versions
interface IUpgradeManager {
    /// @notice Parameters for updating specific storage slot values
    struct StorageUpdate {
        bytes32 slot; // Target storage slot
        bytes32 currentValue; // Expected current value
        bytes32 newValue; // Value to set
    }

    /// @notice Returns the StorageSetter contract used for storage layout migrations
    /// @return The StorageSetter contract instance
    function storageSetter() external view returns (StorageSetter);

    /// @notice Returns the L1BuildAgent contract used for deployment orchestration
    /// @return The BuildAgent contract interface
    function buildAgent() external view returns (IL1BuildAgent);

    /// @notice Returns the ProxyAdmin contract for a specific chain
    /// @param _chainId Chain ID of the verse network
    /// @return The ProxyAdmin contract instance for the specified chain
    function proxyAdmin(uint256 _chainId) external view returns (ProxyAdmin);

    /// @notice Upgrades a proxy contract implementation
    /// @param _chainId Chain ID of the verse network
    /// @param _proxy Address of the proxy contract to upgrade
    /// @param _implementation Address of the new implementation contract
    function upgrade(uint256 _chainId, address _proxy, address _implementation) external;

    /// @notice Upgrades a proxy contract implementation with storage modification
    /// @dev Performs storage update before changing implementation
    /// @param _chainId Chain ID of the verse network
    /// @param _proxy Address of the proxy contract to upgrade
    /// @param _implementation Address of the new implementation contract
    /// @param _storageUpdate Storage slot modification details
    function upgrade(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        StorageUpdate memory _storageUpdate
    )
        external;

    /// @notice Upgrades a proxy contract and calls an some function
    /// @param _chainId Chain ID of the verse network
    /// @param _proxy Address of the proxy contract to upgrade
    /// @param _implementation Address of the new implementation contract
    /// @param _data Call data for some function
    function upgradeAndCall(uint256 _chainId, address _proxy, address _implementation, bytes memory _data) external;

    /// @notice Upgrades a proxy contract and calls an some function with storage modification
    /// @dev Performs storage update before changing implementation
    /// @param _chainId Chain ID of the verse network
    /// @param _proxy Address of the proxy contract to upgrade
    /// @param _implementation Address of the new implementation contract
    /// @param _data Call data for some function
    /// @param _storageUpdate Storage slot modification details
    function upgradeAndCall(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        bytes memory _data,
        StorageUpdate memory _storageUpdate
    )
        external;
}
