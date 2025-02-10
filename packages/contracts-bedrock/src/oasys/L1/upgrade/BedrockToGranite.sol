// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Openzeppelin Libraries
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

// Interfaces
import { ISemver } from "src/universal/ISemver.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IOasysL2OutputOracleVerifier } from "src/oasys/L1/interfaces/IOasysL2OutputOracleVerifier.sol";
import { IUpgradeManager } from "src/oasys/L1/upgrade/IUpgradeManager.sol";
import { IUpgradeImplementer } from "src/oasys/L1/upgrade/IUpgradeImplementer.sol";

// New version implementations
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";

// Dependencies
import { Constants } from "src/libraries/Constants.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { StorageSetter } from "src/universal/StorageSetter.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";

// solhint-disable max-line-length
/// @notice Interface for OasysPortal v1.11.0
/// https://github.com/oasysgames/oasys-opstack/blob/v1.1.0/packages/contracts-bedrock/src/oasys/L1/messaging/OasysPortal.sol
interface IPrevOasysPortal {
    function messageRelayer() external view returns (address);
}

// solhint-disable func-name-mixedcase,max-line-length
/// @notice Interface for OasysL2OutputOracle v1.7.0
/// https://github.com/oasysgames/oasys-opstack/blob/v1.1.0/packages/contracts-bedrock/src/oasys/L1/rollup/OasysL2OutputOracle.sol
interface IPrevOasysL2OutputOracle {
    function SUBMISSION_INTERVAL() external view returns (uint256);
    function L2_BLOCK_TIME() external view returns (uint256);
    function CHALLENGER() external view returns (address);
    function PROPOSER() external view returns (address);
    function FINALIZATION_PERIOD_SECONDS() external view returns (uint256);
    function VERIFIER() external view returns (IOasysL2OutputOracleVerifier);
    function startingBlockNumber() external view returns (uint256);
    function startingTimestamp() external view returns (uint256);
}

/// @notice Interface for SystemConfig v1.11.0
/// https://github.com/oasysgames/oasys-opstack/blob/v1.1.0/packages/contracts-bedrock/src/L1/SystemConfig.sol
interface IPrevSystemConfig {
    struct ResourceConfig {
        uint32 maxResourceLimit;
        uint8 elasticityMultiplier;
        uint8 baseFeeMaxChangeDenominator;
        uint32 minimumBaseFee;
        uint32 systemTxMaxGas;
        uint128 maximumBaseFee;
    }

    function owner() external view returns (address);
    function overhead() external view returns (uint256);
    function scalar() external view returns (uint256);
    function batcherHash() external view returns (bytes32);
    function gasLimit() external view returns (uint64);
    function unsafeBlockSigner() external view returns (address);
    function resourceConfig() external view returns (ResourceConfig calldata);
}

/// @title BedrockToGranite
/// @notice An implementation contract for upgrading the network from Bedrock to Granite.
contract BedrockToGranite is IERC165, ISemver, IUpgradeImplementer {
    /// @notice Stores proxy addresses for L1 contracts
    struct Proxies {
        address superchainConfig;
        address optimismPortal;
        address l2OutputOracle;
        address systemConfig;
        address l1CrossDomainMessenger;
        address l1StandardBridge;
        address l1ERC721Bridge;
    }

    /// @notice New implementation addresses
    /// @dev Safe to share across networks as this contract is called via proxy
    address public immutable SUPERCHAIN_CONFIG;
    address public immutable OPTIMISM_PORTAL;
    address public immutable L2_OUTPUT_ORACLE;
    address public immutable SYSTEM_CONFIG;
    address public immutable L1_CROSS_DOMAIN_MESSENGER;
    address public immutable L1_STANDARD_BRIDGE;
    address public immutable L1_ERC721_BRIDGE;

    /// @notice Mapping of chain IDs to their proxy addresses
    mapping(uint256 => Proxies) public proxies;

    /// @notice Check if the caller supports the IUpgradeManager interface
    modifier onlyUpgradeManager() {
        require(
            ERC165Checker.supportsInterface(msg.sender, type(IUpgradeManager).interfaceId),
            "BedrockToGranite: caller is not L1UpgradeManager"
        );
        _;
    }

    /// @notice Initializes the implementer
    constructor(
        address _superchainConfig,
        address _optimismPortal,
        address _l2OutputOracle,
        address _systemConfig,
        address _l1CrossDomainMessenger,
        address _l1StandardBridge,
        address _l1ERC721Bridge
    ) {
        require(
            _superchainConfig.codehash == 0xcb9fc87911d60025ea59380a275f6ecda28b4c35a143e6ad3fa2d75a1381a993,
            "BedrockToGranite: SuperchainConfig(1.1.0) is required"
        );
        require(
            _optimismPortal.codehash == 0x700743357dbb48d614b0fd259ab8ccadcabc0a7d838ea1d06c3cd0f7ea1a3fdb,
            "BedrockToGranite: OasysPortal(2.8.0) is required"
        );
        require(
            _l2OutputOracle.codehash == 0xc62cead15355b12f0efd1869bf7c4685877e18817768f62b75082123902d5c5b,
            "BedrockToGranite: OasysL2OutputOracle(1.8.0) is required"
        );
        require(
            _systemConfig.codehash == 0xaaa3dd560a1101c438a36454b4d99c5e0072b13267fcf0db2c3ab087f2606f3d,
            "BedrockToGranite: SystemConfig(2.2.0) is required"
        );
        require(
            _l1CrossDomainMessenger.codehash == 0xa8ca2b584e2fdfc4617078021e0d126666865647576b68c4fd777025feabfb47,
            "BedrockToGranite: L1CrossDomainMessenger(2.4.0) is required"
        );
        require(
            _l1StandardBridge.codehash == 0x3349133652f0639bf1fc161af97c3cb4091021de544c14e9c3d93e92db869783,
            "BedrockToGranite: L1StandardBridge(2.2.0) is required"
        );
        require(
            _l1ERC721Bridge.codehash == 0xae7b9c7b34f268619b622cd8bb12b166952f41ec04259a42952bedd0393540ca,
            "BedrockToGranite: L1ERC721Bridge(2.1.0) is required"
        );

        _checkVersion("SuperchainConfig", _superchainConfig, "1.1.0");
        _checkVersion("OptimismPortal", _optimismPortal, "2.8.0");
        _checkVersion("L2OutputOracle", _l2OutputOracle, "1.8.0");
        _checkVersion("SystemConfig", _systemConfig, "2.2.0");
        _checkVersion("L1CrossDomainMessenger", _l1CrossDomainMessenger, "2.4.0");
        _checkVersion("L1StandardBridge", _l1StandardBridge, "2.2.0");
        _checkVersion("L1ERC721Bridge", _l1ERC721Bridge, "2.1.0");

        SUPERCHAIN_CONFIG = _superchainConfig;
        OPTIMISM_PORTAL = _optimismPortal;
        L2_OUTPUT_ORACLE = _l2OutputOracle;
        SYSTEM_CONFIG = _systemConfig;
        L1_CROSS_DOMAIN_MESSENGER = _l1CrossDomainMessenger;
        L1_STANDARD_BRIDGE = _l1StandardBridge;
        L1_ERC721_BRIDGE = _l1ERC721Bridge;
    }

    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IUpgradeImplementer
    uint256 public constant implementerIndex = 0;

    /// @inheritdoc IUpgradeImplementer
    string public constant upgradeName = "Granite";

    /// @inheritdoc IUpgradeImplementer
    uint256 public constant totalSteps = 1;

    /// @notice Checks if the contract supports an interface.
    ///         Expected to be called from manager contracts
    /// @param _interfaceId Interface identifier to check
    function supportsInterface(bytes4 _interfaceId) public pure override(IERC165) returns (bool) {
        return _interfaceId == type(IUpgradeImplementer).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IUpgradeImplementer
    function executeUpgradeStep(uint256 _chainId, uint8 _step) external onlyUpgradeManager returns (bool _completed) {
        require(_step == 1, "BedrockToGranite: step must be 1");

        _initialize(_chainId);
        _deploySuperchainConfigProxy(_chainId);
        _upgradeSuperchainConfig(_chainId);
        _upgradeOptimismPortal(_chainId);
        _upgradeOasysL2OutputOracle(_chainId);
        _upgradeSystemConfig(_chainId);
        _upgradeL1CrossDomainMessenger(_chainId);
        _upgradeL1StandardBridge(_chainId);
        _upgradeL1ERC721Bridge(_chainId);
        return true;
    }

    /// @dev Initializes the upgrade process by loading and validating current contract versions
    /// @param _chainId Chain identifier
    function _initialize(uint256 _chainId) internal {
        // slither-disable-next-line unused-return
        (
            ,
            address _systemConfig,
            address _l1StandardBridge,
            address _l1ERC721Bridge,
            address _l1CrossDomainMessenger,
            address _l2OutputOracle,
            address _optimismPortal,
            ,
        ) = _buildAgent().builtLists(_chainId);

        _checkVersion("SystemConfig", _systemConfig, "1.11.0");
        _checkVersion("L1StandardBridge", _l1StandardBridge, "1.5.0");
        _checkVersion("L1ERC721Bridge", _l1ERC721Bridge, "1.5.0");
        _checkVersion("L1CrossDomainMessenger", _l1CrossDomainMessenger, "1.8.0");
        _checkVersion("L2OutputOracle", _l2OutputOracle, "1.7.0");
        _checkVersion("OptimismPortal", _optimismPortal, "1.11.0");

        proxies[_chainId] = Proxies({
            superchainConfig: address(0),
            optimismPortal: _optimismPortal,
            l2OutputOracle: _l2OutputOracle,
            systemConfig: _systemConfig,
            l1CrossDomainMessenger: _l1CrossDomainMessenger,
            l1StandardBridge: _l1StandardBridge,
            l1ERC721Bridge: _l1ERC721Bridge
        });
    }

    /// @notice Deploys a new SuperchainConfig proxy contract
    /// @param _chainId Chain identifier
    function _deploySuperchainConfigProxy(uint256 _chainId) internal {
        Proxy _proxy = new Proxy({ _admin: address(_manager().proxyAdmin(_chainId)) });
        proxies[_chainId].superchainConfig = address(_proxy);

        emit ProxyDeployed(_chainId, "SuperchainConfig", address(_proxy));
    }

    /// @notice Upgrades SuperchainConfig implementation
    /// @param _chainId Chain identifier
    function _upgradeSuperchainConfig(uint256 _chainId) internal {
        IPrevSystemConfig sysCfg = IPrevSystemConfig(proxies[_chainId].systemConfig);

        _manager().upgradeAndCall({
            _chainId: _chainId,
            _proxy: proxies[_chainId].superchainConfig,
            _implementation: SUPERCHAIN_CONFIG,
            _data: abi.encodeCall(
                SuperchainConfig.initialize,
                (
                    sysCfg.owner(), // _guardian
                    false // _paused
                )
            )
        });
    }

    /// @notice Upgrades OptimismPortal implementation with re-initialization
    /// @param _chainId Chain identifier
    function _upgradeOptimismPortal(uint256 _chainId) internal {
        IPrevOasysPortal prev = IPrevOasysPortal(proxies[_chainId].optimismPortal);

        _manager().upgradeAndCallWithStorageUpdate({
            _chainId: _chainId,
            _proxy: proxies[_chainId].optimismPortal,
            _implementation: OPTIMISM_PORTAL,
            _data: abi.encodeCall(
                OasysPortal.initializeWithRelayer,
                (
                    L2OutputOracle(proxies[_chainId].l2OutputOracle),
                    SystemConfig(proxies[_chainId].systemConfig),
                    SuperchainConfig(proxies[_chainId].superchainConfig),
                    prev.messageRelayer()
                )
            ),
            _storageUpdate: IUpgradeManager.StorageUpdate({
                slot: bytes32(0),
                currentValue: bytes32(uint256(1)),
                newValue: bytes32(0)
            })
        });
    }

    /// @notice Upgrades L2OutputOracle implementation with re-initialization
    /// @param _chainId Chain identifier
    function _upgradeOasysL2OutputOracle(uint256 _chainId) internal {
        IPrevOasysL2OutputOracle prev = IPrevOasysL2OutputOracle(proxies[_chainId].l2OutputOracle);

        _manager().upgradeAndCallWithStorageUpdate({
            _chainId: _chainId,
            _proxy: proxies[_chainId].l2OutputOracle,
            _implementation: L2_OUTPUT_ORACLE,
            _data: abi.encodeCall(
                OasysL2OutputOracle.initialize,
                (
                    prev.SUBMISSION_INTERVAL(),
                    prev.L2_BLOCK_TIME(),
                    prev.startingBlockNumber(),
                    prev.startingTimestamp(),
                    prev.PROPOSER(),
                    prev.CHALLENGER(),
                    prev.FINALIZATION_PERIOD_SECONDS(),
                    prev.VERIFIER()
                )
            ),
            _storageUpdate: IUpgradeManager.StorageUpdate({
                slot: bytes32(0),
                currentValue: bytes32(uint256(1)),
                newValue: bytes32(0)
            })
        });
    }

    /// @notice Upgrades SystemConfig implementation with re-initialization
    /// @param _chainId Chain identifier
    function _upgradeSystemConfig(uint256 _chainId) internal {
        IPrevSystemConfig prev = IPrevSystemConfig(proxies[_chainId].systemConfig);

        (ResourceMetering.ResourceConfig memory cfg, SystemConfig.Addresses memory addrs) =
            _systemConfigInitializeParams(_chainId);

        // slither-disable-next-line unused-return
        (,,,,,,,, address batchInbox) = _buildAgent().builtLists(_chainId);

        _manager().upgradeAndCallWithStorageUpdate({
            _chainId: _chainId,
            _proxy: proxies[_chainId].systemConfig,
            _implementation: SYSTEM_CONFIG,
            _data: abi.encodeCall(
                SystemConfig.initialize,
                (
                    prev.owner(),
                    prev.overhead(),
                    prev.scalar(),
                    prev.batcherHash(),
                    prev.gasLimit(),
                    prev.unsafeBlockSigner(),
                    cfg,
                    batchInbox,
                    addrs
                )
            ),
            _storageUpdate: IUpgradeManager.StorageUpdate({
                slot: bytes32(0),
                currentValue: bytes32(uint256(1)),
                newValue: bytes32(0)
            })
        });
    }

    /// @notice Returns initialization parameters for SystemConfig upgrade
    /// @notice Split into separate function to avoid `stack too deep` errors
    /// @param _chainId Chain identifier
    /// @return ResourceConfig configuration for resource metering
    /// @return Addresses L1 contract addresses required for SystemConfig
    function _systemConfigInitializeParams(uint256 _chainId)
        internal
        view
        returns (ResourceMetering.ResourceConfig memory, SystemConfig.Addresses memory)
    {
        IPrevSystemConfig prev = IPrevSystemConfig(proxies[_chainId].systemConfig);
        IPrevSystemConfig.ResourceConfig memory cfg = prev.resourceConfig();
        return (
            ResourceMetering.ResourceConfig({
                maxResourceLimit: cfg.maxResourceLimit,
                elasticityMultiplier: cfg.elasticityMultiplier,
                baseFeeMaxChangeDenominator: cfg.baseFeeMaxChangeDenominator,
                minimumBaseFee: cfg.minimumBaseFee,
                systemTxMaxGas: cfg.systemTxMaxGas,
                maximumBaseFee: cfg.maximumBaseFee
            }),
            SystemConfig.Addresses({
                l1CrossDomainMessenger: proxies[_chainId].l1CrossDomainMessenger,
                l1ERC721Bridge: proxies[_chainId].l1ERC721Bridge,
                l1StandardBridge: proxies[_chainId].l1StandardBridge,
                optimismPortal: proxies[_chainId].optimismPortal,
                gasPayingToken: Constants.ETHER,
                disputeGameFactory: address(0), // Not used in the Oasys
                optimismMintableERC20Factory: address(0) // Not used in the Oasys
             })
        );
    }

    /// @notice Upgrades L1CrossDomainMessenger implementation with re-initialization
    /// @param _chainId Chain identifier
    function _upgradeL1CrossDomainMessenger(uint256 _chainId) internal {
        address addressManager = address(_manager().proxyAdmin(_chainId).addressManager());

        _manager().upgradeAndCallWithStorageUpdate({
            _chainId: _chainId,
            _proxy: proxies[_chainId].l1CrossDomainMessenger,
            _implementation: L1_CROSS_DOMAIN_MESSENGER,
            _data: abi.encodeCall(
                L1CrossDomainMessenger.initialize,
                (
                    SuperchainConfig(proxies[_chainId].superchainConfig),
                    OptimismPortal(payable(proxies[_chainId].optimismPortal)),
                    SystemConfig(proxies[_chainId].systemConfig)
                )
            ),
            _storageUpdate: IUpgradeManager.StorageUpdate({
                slot: bytes32(0),
                // Pack `spacer_0_0_20(address)+_initialized(uint8)` with right alignment
                currentValue: bytes32(uint256(1) << 8 * 20 | uint160(addressManager)),
                newValue: bytes32(uint256(0) << 8 * 20 | uint160(addressManager))
            })
        });
    }

    /// @notice Upgrades L1StandardBridge implementation with version-specific initialization
    /// @param _chainId Chain identifier
    function _upgradeL1StandardBridge(uint256 _chainId) internal {
        bytes memory data = abi.encodeCall(
            L1StandardBridge.initialize,
            (
                L1CrossDomainMessenger(proxies[_chainId].l1CrossDomainMessenger),
                SuperchainConfig(proxies[_chainId].superchainConfig),
                SystemConfig(proxies[_chainId].systemConfig)
            )
        );

        // slither-disable-next-line unused-return
        (bool hasV0,) = _buildAgent().isUpgradingExistingL2(_chainId);
        if (hasV0) {
            // When upgrading from v0:
            //   - slot0 contains the messenger address (right-aligned)
            //   - must shift left by 2bytes to accommodate Initializable flags
            //   - preserves messenger address while allowing proper initialization
            _manager().upgradeAndCallWithStorageUpdate({
                _chainId: _chainId,
                _proxy: proxies[_chainId].l1StandardBridge,
                _implementation: L1_STANDARD_BRIDGE,
                _data: data,
                _storageUpdate: IUpgradeManager.StorageUpdate({
                    slot: bytes32(0),
                    // Pack `_initialized(uint8)+_initializing(bool)+spacer_0_2_30(bytes30)` with right alignment
                    currentValue: bytes32(uint256(uint160(proxies[_chainId].l1CrossDomainMessenger))),
                    newValue: bytes32(uint256(uint160(proxies[_chainId].l1CrossDomainMessenger)) << 8 * 2)
                })
            });
        } else {
            _manager().upgradeAndCall({
                _chainId: _chainId,
                _proxy: proxies[_chainId].l1StandardBridge,
                _implementation: L1_STANDARD_BRIDGE,
                _data: data
            });
        }
    }

    /// @notice Upgrades L1ERC721Bridge implementation
    /// @param _chainId Chain identifier
    function _upgradeL1ERC721Bridge(uint256 _chainId) internal {
        // Storage adjustment is not required for L1ERC721Bridge because OasysERC721BridgeLegacySpacers
        // ensures sufficient gaps, so Initializable will use a new storage slot.
        _manager().upgradeAndCall({
            _chainId: _chainId,
            _proxy: proxies[_chainId].l1ERC721Bridge,
            _implementation: L1_ERC721_BRIDGE,
            _data: abi.encodeCall(
                L1ERC721Bridge.initialize,
                (
                    L1CrossDomainMessenger(payable(proxies[_chainId].l1CrossDomainMessenger)),
                    SuperchainConfig(proxies[_chainId].superchainConfig)
                )
            )
        });
    }

    /// @notice Returns the upgrade manager contract that called this contract
    /// @return IUpgradeManager interface of the caller
    function _manager() internal view returns (IUpgradeManager) {
        return IUpgradeManager(msg.sender);
    }

    /// @notice Returns the build agent contract through the upgrade manager
    /// @return IL1BuildAgent interface of the build agent
    function _buildAgent() internal view returns (IL1BuildAgent) {
        return _manager().buildAgent();
    }

    /// @notice Verifies that a contract's version matches the expected version
    /// @dev Reverts if versions don't match, with detailed error message
    /// @param _contractName Name of the contract for error messages
    /// @param _contractAddr Address of the contract to check
    /// @param _expectVersion Expected semantic version string
    function _checkVersion(
        string memory _contractName,
        address _contractAddr,
        string memory _expectVersion
    )
        internal
        view
    {
        string memory actualVersion = ISemver(_contractAddr).version();
        require(
            keccak256(bytes(actualVersion)) == keccak256(bytes(_expectVersion)),
            string.concat(
                "BedrockToGranite: ",
                _contractName,
                " is unexpected version(actual=",
                actualVersion,
                ", expect=",
                _expectVersion,
                ")"
            )
        );
    }
}
