// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Openzeppelin Libraries
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

// Interfaces
import { ISemver } from "src/universal/ISemver.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IUpgradeManager } from "src/oasys/L1/upgrade/IUpgradeManager.sol";
import { IUpgradeImplementer } from "src/oasys/L1/upgrade/IUpgradeImplementer.sol";

// Dependencies
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { StorageSetter } from "src/universal/StorageSetter.sol";

/// @custom:proxied
/// @title UpgradeManager
/// @notice Manages the upgrade process for proxy contracts across multiple Verse-Layers.
///         This contract coordinates the upgrade process, managing ownership transfers and implementation updates.
///         ----
///         # How to Use
///         ## Prerequisites
///         - Only the owner of ProxyAdmin can execute upgrades.
///         - L2 node components (such as op-geth and op-node) must be stopped during the upgrade process.
///         - After the upgrade, all L2 components need to be updated to their corresponding versions.
///
///         ## Upgrade Process
///         ### Step 1: Register Ownership
///         First, register yourself as the ProxyAdmin owner:
///
///         ```solidity
///         upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);
///         ```
///
///         ### Step 2: Transfer Ownership
///         Transfer the ProxyAdmin ownership to the UpgradeManager contract.
///
///         ```solidity
///         proxyAdmin.transferOwnership(address(upgradeManager));
///         ```
///
///         > [!CAUTION]
///         > Please be very careful as the transfer of ownership is irrevocable.
///           An incorrect transfer will result in permanent loss of control of the L2.
///
///         ### Step 3: Execute Upgrade
///         Call the upgrade function to start the process:
///
///         ```solidity
///         upgradeManager.upgradeContracts(chainId);
///         ```
///
///         ### Step 4: Completion
///         The upgrade process automatically returns ProxyAdmin ownership to the registerd owner upon completion.
///         Upgrade the L2 components to their corresponding versions and start the node.
///
///         ## Important Notes
///         - Each step in the upgrade process must be completed sequentially.
///         - If you have transferred ownership of ProxyAdmin before executing
///           "Step 1: Register Ownership", please contact the owner of UpgradeManager.
///           The UpgradeManager owner performs the return of ownership.
///         - The process can be monitored through emitted events.
///
contract UpgradeManager is IERC165, ISemver, IUpgradeManager, Ownable {
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

    /// @dev Tracks the status of an upgrade for each chain
    struct Status {
        // Index of the current upgrade implementer
        uint8 implementerIndex;
        // The step number to execute in the current upgrade process
        uint8 step;
    }

    /// @inheritdoc IUpgradeManager
    StorageSetter public immutable storageSetter;

    /// @inheritdoc IUpgradeManager
    IL1BuildAgent public immutable buildAgent;

    // List of upgrade implementers
    IUpgradeImplementer[] public implementers;

    // List of original owner of ProxyAdmin for each L2 Chain ID
    mapping(uint256 => address) public proxyAdminOwners;

    // List of upgrade status for each L2 Chain ID
    mapping(uint256 => Status) public statuses;

    /// @notice Validates that the chain ID corresponds to a registered chain
    /// @param _chainId The chain ID to validate
    modifier validChainId(uint256 _chainId) {
        // slither-disable-next-line unused-return
        (address _proxyAdmin,,,,,,,,) = buildAgent.builtLists(_chainId);
        require(_proxyAdmin != address(0), "UpgradeManager: invalid chain-id");
        _;
    }

    /// @notice Ensures the caller is the designated owner for the ProxyAdmin
    /// @param _chainId The chain ID to check ownership for
    modifier onlyProxyAdminOwner(uint256 _chainId) {
        address _owner = proxyAdminOwners[_chainId];
        require(_owner != address(0), "UpgradeManager: not prepared");
        require(_owner == msg.sender, "UpgradeManager: caller is not the ProxyAdmin owner");
        _;
    }

    /// @notice Ensures the caller is the current implementer for the chain
    /// @param _chainId The chain ID to check implementer for
    modifier onlyCurrentImplementer(uint256 _chainId) {
        require(
            msg.sender == address(_getImplementer(statuses[_chainId].implementerIndex)),
            "UpgradeManager: inconsistent implementer"
        );
        _;
    }

    /// @notice Initializes the upgrade manager
    /// @param _owner Address that will own this contract
    /// @param _buildAgent Address of the BuildAgent contract
    constructor(address _owner, address _buildAgent) {
        require(_owner != address(0), "UpgradeManager: owner is zero address");
        transferOwnership(_owner);

        require(_buildAgent != address(0), "UpgradeManager: buildAgent is zero address");
        buildAgent = IL1BuildAgent(_buildAgent);

        storageSetter = new StorageSetter();
    }

    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    function version() public pure virtual returns (string memory) {
        return "1.0.0";
    }

    /// @notice Checks if the contract supports an interface.
    ///         Expected to be called from implementer contracts
    /// @param _interfaceId Interface identifier to check
    function supportsInterface(bytes4 _interfaceId) public pure override(IERC165) returns (bool) {
        return _interfaceId == type(IUpgradeManager).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }

    /// @notice Add a new implementer to the manager
    /// @param _implementer Address of the new implementer
    function addNextImplementer(IUpgradeImplementer _implementer) external onlyOwner {
        require(
            ERC165Checker.supportsInterface(address(_implementer), type(IUpgradeImplementer).interfaceId),
            "UpgradeManager: implementer must support IUpgradeImplementer"
        );
        require(_implementer.implementerIndex() == implementers.length, "UpgradeManager: invalid implementer index");

        implementers.push(_implementer);

        emit ImplementerAdded(address(_implementer), _implementer.implementerIndex(), _implementer.upgradeName());
    }

    /// @notice Registers the original ProxyAdmin owner before the ownership transfer.
    ///         This method must be called before transferring ProxyAdmin ownership.
    ///         If ownership has already been transferred, please contact the
    ///         UpgradeManager owner to release the ownership.
    /// @param _chainId Target chain ID for the registration
    function registerProxyAdminOwnerBeforeTransfer(uint256 _chainId) external validChainId(_chainId) {
        require(proxyAdminOwners[_chainId] == address(0), "UpgradeManager: already prepared");

        address _owner = proxyAdmin(_chainId).owner();
        require(
            _owner != address(this),
            string.concat(
                "UpgradeManager: ProxyAdmin ownership has been transferred before preparation.",
                " Please contact the UpgradeManager owner to restore ownership."
            )
        );

        require(_owner == msg.sender, "UpgradeManager: caller is not the ProxyAdmin owner");

        _registerProxyAdminOwner(_chainId, _owner);
    }

    /// @dev This method executes the upgrade process for registered proxy contracts.
    ///      The caller must be the ProxyAdmin owner for the specified chain.
    ///      All necessary preparations (implementation deployment, ownership registration)
    ///      must be completed before calling this.
    /// @param _chainId Target chain ID for the upgrade
    function upgradeContracts(uint256 _chainId) external validChainId(_chainId) onlyProxyAdminOwner(_chainId) {
        require(
            proxyAdmin(_chainId).owner() == address(this),
            "UpgradeManager: please transfer ProxyAdmin ownership to UpgradeManager"
        );

        Status storage status = statuses[_chainId];
        IUpgradeImplementer implementer = _getImplementer(status.implementerIndex);

        status.step += 1;
        bool _completed = implementer.executeUpgradeStep(_chainId, status.step);

        emit UpgradeStepAdvanced(_chainId, implementer.upgradeName(), status.step, implementer.totalSteps());

        if (_completed) {
            // slither-disable-next-line reentrancy-no-eth
            status.implementerIndex += 1;
            // slither-disable-next-line reentrancy-no-eth
            status.step = 0;
            _releaseProxyAdminOwner(_chainId);

            emit UpgradeCompleted(_chainId, implementer.upgradeName());
        }
    }

    /// @inheritdoc IUpgradeManager
    function proxyAdmin(uint256 _chainId) public view returns (ProxyAdmin) {
        // slither-disable-next-line unused-return
        (address _proxyAdmin,,,,,,,,) = buildAgent.builtLists(_chainId);
        return ProxyAdmin(_proxyAdmin);
    }

    /// @notice Releases the ownership of the ProxyAdmin for the specified chain to the original owner
    /// @param _chainId Chain identifier
    function releaseProxyAdminOwnership(uint256 _chainId)
        external
        validChainId(_chainId)
        onlyProxyAdminOwner(_chainId)
    {
        _releaseProxyAdminOwner(_chainId);
    }

    /// @notice Transfers ProxyAdmin ownership to an arbitrary address at the discretion of the UpgradeManager owner
    /// @param _chainId The chain ID to transfer the owner for
    /// @param _owner The address to transfer as the owner
    function transferProxyAdminOwner(uint256 _chainId, address _owner) external onlyOwner validChainId(_chainId) {
        _registerProxyAdminOwner(_chainId, _owner);
        _releaseProxyAdminOwner(_chainId);
    }

    /// @inheritdoc IUpgradeManager
    function upgrade(
        uint256 _chainId,
        address _proxy,
        address _implementation
    )
        external
        onlyCurrentImplementer(_chainId)
    {
        _upgrade(_chainId, _proxy, _implementation, new bytes(0));
    }

    /// @inheritdoc IUpgradeManager
    function upgrade(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        StorageUpdate memory _storageUpdate
    )
        external
        onlyCurrentImplementer(_chainId)
    {
        _upgrade(_chainId, _proxy, _implementation, new bytes(0), _storageUpdate);
    }

    /// @inheritdoc IUpgradeManager
    function upgradeAndCall(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        bytes memory _data
    )
        external
        onlyCurrentImplementer(_chainId)
    {
        _upgrade(_chainId, _proxy, _implementation, _data);
    }

    /// @inheritdoc IUpgradeManager
    function upgradeAndCall(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        bytes memory _data,
        StorageUpdate memory _storageUpdate
    )
        external
        onlyCurrentImplementer(_chainId)
    {
        _upgrade(_chainId, _proxy, _implementation, _data, _storageUpdate);
    }

    /// @notice Sets the owner of the ProxyAdmin for a chain
    /// @param _chainId The chain ID to set the owner for
    /// @param _owner The address to set as the owner
    function _registerProxyAdminOwner(uint256 _chainId, address _owner) internal {
        require(_owner != address(0), "UpgradeManager: owner is zero address");

        proxyAdminOwners[_chainId] = _owner;

        emit ProxyAdminOwnerRegistered(_chainId, _owner);
    }

    /// @notice Transfer ProxyAdmin ownership to the original owner
    function _releaseProxyAdminOwner(uint256 _chainId) internal {
        ProxyAdmin _proxyAdmin = proxyAdmin(_chainId);
        require(_proxyAdmin.owner() == address(this), "UpgradeManager: has no ownership");

        address _owner = proxyAdminOwners[_chainId];
        proxyAdminOwners[_chainId] = address(0);

        _proxyAdmin.transferOwnership(_owner);

        emit ProxyAdminOwnerReleased(_chainId, _owner);
    }

    /// @notice Retrieves an implementer by index with bounds checking
    function _getImplementer(uint8 _index) internal view returns (IUpgradeImplementer) {
        require(implementers.length > 0, "UpgradeManager: no implementers");
        require(_index < implementers.length, "UpgradeManager: your network is up-to-date");
        return implementers[_index];
    }

    /// @notice Upgrades a proxy contract implementation
    function _upgrade(uint256 _chainId, address _proxy, address _implementation, bytes memory _data) internal {
        require(_implementation != address(0), "UpgradeManager: implementation is zero address");

        if (_data.length == 0) {
            proxyAdmin(_chainId).upgrade({ _proxy: payable(_proxy), _implementation: _implementation });
        } else {
            proxyAdmin(_chainId).upgradeAndCall({
                _proxy: payable(_proxy),
                _implementation: _implementation,
                _data: _data
            });
        }

        emit ProxyUpgraded(_chainId, _proxy, _implementation);
    }

    /// @notice Upgrades a proxy contract implementation with storage modification
    function _upgrade(
        uint256 _chainId,
        address _proxy,
        address _implementation,
        bytes memory _data,
        StorageUpdate memory _storageUpdate
    )
        internal
    {
        // Temporarily upgrades to StorageSetter
        _upgrade(_chainId, _proxy, address(storageSetter), new bytes(0));

        // Check if the current slot value matches the expected value
        bytes32 actual = StorageSetter(_proxy).getBytes32(_storageUpdate.slot);
        require(actual == _storageUpdate.currentValue, "UpgradeManager: unexpected slot value");

        // Updates the storage slot with the new value
        StorageSetter(_proxy).setBytes32(_storageUpdate.slot, _storageUpdate.newValue);

        // Upgrade to the new implementation
        _upgrade(_chainId, _proxy, _implementation, _data);
    }
}
