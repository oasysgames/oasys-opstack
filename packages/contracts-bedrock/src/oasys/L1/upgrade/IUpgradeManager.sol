// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { StorageSetter } from "src/universal/StorageSetter.sol";

/// @title IUpgradeManager
/// @notice Interface for managing L2 upgrades across multiple versions
interface IUpgradeManager {
    /// @notice Emitted when a new upgrade implementer is added to the manager
    /// @param implementer The address of the newly added implementer
    /// @param implementerIndex The index assigned to the implementer
    /// @param upgradeName The name of the implementer
    event ImplementerAdded(address indexed implementer, uint256 indexed implementerIndex, string indexed upgradeName);

    /// @notice Emitted when a ProxyAdmin owner is registered
    /// @param chainId The Chain ID of the target Verse-Layer
    /// @param owner The address of the registered owner
    event ProxyAdminOwnerRegistered(uint256 indexed chainId, address indexed owner);

    /// @notice Emitted when a ProxyAdmin owner is released
    /// @param chainId The Chain ID of the target Verse-Layer
    /// @param owner The owner address to release to
    event ProxyAdminOwnerReleased(uint256 indexed chainId, address indexed owner);

    /// @notice Emitted when a proxy contract's implementation is upgraded
    /// @param chainId The Chain ID of the target Verse-Layer
    /// @param proxy The address of the proxy contract that was upgraded
    /// @param implementation The address of the new implementation
    event ProxyUpgraded(uint256 indexed chainId, address indexed proxy, address implementation);

    /// @notice Emitted when the upgrade process advances a step
    /// @param chainId The Chain ID of the target Verse-Layer
    /// @param upgradeName The name of the current upgrade process
    /// @param step The current step number that was completed
    /// @param totalSteps The total number of steps in the upgrade process
    event UpgradeStepAdvanced(uint256 indexed chainId, string indexed upgradeName, uint256 step, uint256 totalSteps);

    /// @notice Emitted when an upgrade process is fully completed
    /// @param chainId The Chain ID of the target Verse-Layer
    /// @param upgradeName The name of the completed upgrade process
    event UpgradeCompleted(uint256 indexed chainId, string indexed upgradeName);

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
    function upgradeWithStorageUpdate(
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
    function upgradeAndCallWithStorageUpdate(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        bytes memory _data,
        StorageUpdate memory _storageUpdate
    )
        external;
}
