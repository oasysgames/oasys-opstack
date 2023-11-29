// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { ISemver } from "src/universal/ISemver.sol";
import { Constants } from "src/libraries/Constants.sol";
import { Predeploys } from "src/libraries/Predeploys.sol";
import { DeployConfig } from "scripts/DeployConfig.s.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IBuildL2OutputOracle } from "src/oasys/L1/build/interfaces/IBuildL2OutputOracle.sol";
import { IBuildOptimismPortal } from "src/oasys/L1/build/interfaces/IBuildOptimismPortal.sol";
import { IBuildL1CrossDomainMessenger } from "src/oasys/L1/build/interfaces/IBuildL1CrossDomainMessenger.sol";
import { IBuildSystemConfig } from "src/oasys/L1/build/interfaces/IBuildSystemConfig.sol";
import { IBuildL1StandardBridge } from "src/oasys/L1/build/interfaces/IBuildL1StandardBridge.sol";
import { IBuildL1ERC721Bridge } from "src/oasys/L1/build/interfaces/IBuildL1ERC721Bridge.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";

/// @notice The 2nd version of L1BuildAgent
///         Regarding the build step, referred to the build script of Opstack
///         Ref:
/// https://github.com/ethereum-optimism/optimism/blob/v1.1.6/packages/contracts-bedrock/scripts/Deploy.s.sol#L67
contract L1BuildAgent is IL1BuildAgent, ISemver {
    /// @notice These hold the bytecodes of the contracts that are deployed by this contract.
    ///         Separate to avoid hitting the contract size limit.
    IBuildL2OutputOracle public immutable BUILD_L2OUTPUT_ORACLE;
    IBuildOptimismPortal public immutable BUILD_OPTIMISM_PORTAL;
    IBuildL1CrossDomainMessenger public immutable BUILD_L1CROSS_DOMAIN_MESSENGER;
    IBuildSystemConfig public immutable BUILD_SYSTEM_CONFIG;
    IBuildL1StandardBridge public immutable BUILD_L1_STANDARD_BRIDGE;
    IBuildL1ERC721Bridge public immutable BUILD_L1_ERC721_BRIDGE;

    /// @notice The address of the L1BuildAgentV1
    ///         Used to ensure that the chainId is unique and not duplicated.
    ILegacyL1BuildAgent public immutable LEGACY_L1_BUILD_AGENT;

    /// @notice The base number to generate batch inbox address
    uint160 public constant BASE_BATCH_INBOX_ADDRESS = uint160(0xfF0000000000000000000000000000000000FF00);

    /// @notice The create2 salt used for deployment of the contract implementations.
    ///         Using this helps to reduce duplicated deployment costs
    bytes32 public constant SALT = keccak256("implementation contract salt");

    /// @notice Semantic version.
    /// @custom:semver 2.0.0
    string public constant version = "2.0.0";

    /// @notice The map of chainId => SystemConfig contract address
    ///         The SystemConfig holds the addresses of the other contracts, So agent don't manage it
    mapping(uint256 => address) public chainSystemConfig;

    /// @notice List of chainIds that have been deployed, Return all chainIds at once
    ///         The size of the array isn't a concern; the limitation lies in the gas cost and comuputaion time.
    ///         Ref:
    /// https://betterprogramming.pub/issues-of-returning-arrays-of-dynamic-size-in-solidity-smart-contracts-dd1e54424235
    uint256[] public chainIds;

    constructor(
        IBuildL2OutputOracle _bOutputOracle,
        IBuildOptimismPortal _bOptimismPortal,
        IBuildL1CrossDomainMessenger _bL1CrossDomainMessenger,
        IBuildSystemConfig _bSystemConfig,
        IBuildL1StandardBridge _bL1StandardBridg,
        IBuildL1ERC721Bridge _bL1ERC721Bridge,
        ILegacyL1BuildAgent _legacyL1BuildAgent
    ) {
        BUILD_L2OUTPUT_ORACLE = _bOutputOracle;
        BUILD_OPTIMISM_PORTAL = _bOptimismPortal;
        BUILD_L1CROSS_DOMAIN_MESSENGER = _bL1CrossDomainMessenger;
        BUILD_SYSTEM_CONFIG = _bSystemConfig;
        BUILD_L1_STANDARD_BRIDGE = _bL1StandardBridg;
        BUILD_L1_ERC721_BRIDGE = _bL1ERC721Bridge;

        LEGACY_L1_BUILD_AGENT = _legacyL1BuildAgent;
    }

    /// @notice Deploy the L1 contract set to build Verse, This is th main function.
    /// @param _chainId The chainId of Verse
    /// @param _cfg The configuration of the L1 contract set
    function build(uint256 _chainId, BuildConfig calldata _cfg) external {
        require(isUniqueChainId(_chainId), "L1BuildAgent: already deployed");

        // temporarily set the admin to this contract
        // transfer ownership to the final system owner at the end of building
        address admin = address(this);

        // deploy proxy contracts for each verse
        (ProxyAdmin proxyAdmin, address[6] memory proxys) = _deployProxies(admin);

        // don't deploy the implementation contracts every time
        // to save gas, reuse the same implementation contract for each proxy
        address[6] memory impls = _deployImplementations(_cfg, proxys);

        // compute the batch inbox address from chainId
        // L2 tx bathch is sent to this address
        address batchInbox = computeInboxAddress(_chainId);

        emit Deployed(_cfg.finalSystemOwner, address(proxyAdmin), proxys, impls, batchInbox);

        // initialize each contracts by calling `initialize` functions through proxys
        _initializeSystemConfig(_cfg, proxyAdmin, impls[2], proxys);
        _initializeL1StandardBridge(proxyAdmin, impls[4], proxys);
        _initializeL1ERC721Bridge(proxyAdmin, impls[5], proxys);
        _initializeL1CrossDomainMessenger(proxyAdmin, impls[3], proxys);
        _initializeL2OutputOracle(_cfg, proxyAdmin, impls[1], proxys);
        _initializeOptimismPortal(proxyAdmin, impls[0], proxys);

        // transfer ownership of the proxy admin to the final system owner
        _transferProxyAdminOwnership(_cfg, proxyAdmin);

        // register `SystemConfig` proxy address to `chainSystemConfig`
        chainSystemConfig[_chainId] = proxys[2];
        // append the chainId to the list
        chainIds.push(_chainId);
    }

    /// @notice Compute inbox address from chainId
    /// @param _chainId The chainId of Verse
    function computeInboxAddress(uint256 _chainId) public pure returns (address) {
        // Assert that the chain ID is less than the max u64, which acts as an implicit limitation
        // Realistically, it is unlikely that any chain would beyond the u64 range.
        require(_chainId <= (1 << 64) - 1, "L1BuildAgent: chainId is too big");
        // Shift the chainId by 8 bits to the left to avoid collisions with other addresses
        return address(uint160(uint64(_chainId) << 16) + BASE_BATCH_INBOX_ADDRESS);
    }

    /// @notice Check if the chainId is unique
    /// @param _chainId The chainId of Verse
    function isUniqueChainId(uint256 _chainId) public view returns (bool) {
        if (LEGACY_L1_BUILD_AGENT == ILegacyL1BuildAgent(address(0))) {
            return _isInternallyUniqueChainId(_chainId);
        }
        return _isInternallyUniqueChainId(_chainId) && LEGACY_L1_BUILD_AGENT.getAddressManager(_chainId) == address(0);
    }

    function _isInternallyUniqueChainId(uint256 _chainId) internal view returns (bool) {
        return chainSystemConfig[_chainId] == address(0);
    }

    function _deployProxies(address admin) internal returns (ProxyAdmin proxyAdmin, address[6] memory proxys) {
        proxyAdmin = new ProxyAdmin({ _owner: admin });
        proxys[0] = _deployProxy(address(proxyAdmin)); // OptimismPortalProxy
        proxys[1] = _deployProxy(address(proxyAdmin)); // L2OutputOracleProxy
        proxys[2] = _deployProxy(address(proxyAdmin)); // SystemConfigProxy

        // TODO: Built L2 uses OVM_L1CrossDomainMessengerProxy and requires special handling.
        proxys[3] = _deployProxy(address(proxyAdmin)); // L1CrossDomainMessengerProxy

        // TODO: Built L2 uses L1ChugSplashProxy and requires special handling.
        proxys[4] = _deployProxy(address(proxyAdmin)); // L1StandardBridgeProxy
        proxys[5] = _deployProxy(address(proxyAdmin)); // L1ERC721BridgeProxy
    }

    /// @notice Deploy the Proxy
    function _deployProxy(address admin) internal returns (address addr) {
        Proxy proxy = new Proxy({ _admin: admin });
        addr = address(proxy);
    }

    /// @notice Deploy all of the implementations
    function _deployImplementations(
        BuildConfig calldata _cfg,
        address[6] memory proxys
    )
        internal
        returns (address[6] memory impls)
    {
        impls[0] = _deployImplementation(
            BUILD_OPTIMISM_PORTAL.deployBytecode({
                _l2Oracle: proxys[1], // L2OutputOracleProxy
                _guardian: _cfg.finalSystemOwner,
                _systemConfig: proxys[2] // SystemConfigProxy
             })
        );

        address _challenger = _cfg.l2OutputOracleChallenger;
        if (_challenger == address(0)) {
            _challenger = _cfg.finalSystemOwner;
        }
        impls[1] = _deployImplementation(
            BUILD_L2OUTPUT_ORACLE.deployBytecode({
                _submissionInterval: _cfg.l2OutputOracleSubmissionInterval,
                _l2BlockTime: _cfg.l2BlockTime,
                _proposer: _cfg.l2OutputOracleProposer,
                _challenger: _challenger,
                _finalizationPeriodSeconds: _cfg.finalizationPeriodSeconds
            })
        );

        impls[2] = _deployImplementation(BUILD_SYSTEM_CONFIG.deployBytecode());

        impls[3] = _deployImplementation(
            BUILD_L1CROSS_DOMAIN_MESSENGER.deployBytecode({
                _portal: payable(proxys[0]) // OptimismPortalProxy
             })
        );

        impls[4] = _deployImplementation(
            BUILD_L1_STANDARD_BRIDGE.deployBytecode({
                _messenger: payable(proxys[3]) // L1CrossDomainMessengerProxy
             })
        );

        impls[5] = _deployImplementation(
            BUILD_L1_ERC721_BRIDGE.deployBytecode({
                _messenger: proxys[3], // L1CrossDomainMessengerProxy
                _otherBridge: Predeploys.L2_ERC721_BRIDGE // TODO: Using Oasys ERC721 bridge?
             })
        );
    }

    function _deployImplementation(bytes memory bytecode) public returns (address addr) {
        addr = Create2.computeAddress(SALT, keccak256(bytecode), address(this));
        // deploy if not already deployed
        if (addr.code.length == 0) {
            addr = Create2.deploy(0, SALT, bytecode);
        }
    }

    /// @notice Initialize the SystemConfig
    function _initializeSystemConfig(
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    )
        internal
    {
        address systemConfigProxy = proxys[2];

        proxyAdmin.upgradeAndCall({
            _proxy: payable(systemConfigProxy),
            _implementation: impl,
            _data: BUILD_SYSTEM_CONFIG.initializeData({
                _owner: _cfg.finalSystemOwner,
                _batcherHash: bytes32(uint256(uint160(_cfg.batchSenderAddress))),
                _config: Constants.DEFAULT_RESOURCE_CONFIG(),
                // This is originally `p2pSequencerAddress` which sign the block for p2p propagation
                // Don't distinguish between sequencer and p2pSequencerAddress(=unsafeBlockSigner)
                _unsafeBlockSigner: _cfg.l2OutputOracleProposer,
                // Same as the OP Mainnet
                _overhead: 188, // gasPriceOracleOverhead
                _scalar: 684_000, // gasPriceOracleScalar
                _gasLimit: 30_000_000 // l2GenesisBlockGasLimit
             })
        });
    }

    /// @notice Initialize the L1StandardBridge
    function _initializeL1StandardBridge(ProxyAdmin proxyAdmin, address impl, address[6] memory proxys) internal {
        address l1StandardBridgeProxy = proxys[4];

        // TODO: Built L2 uses L1ChugSplashProxy and requires special handling.
        proxyAdmin.upgrade({ _proxy: payable(l1StandardBridgeProxy), _implementation: impl });
    }

    /// @notice Initialize the L1ERC721Bridge
    function _initializeL1ERC721Bridge(ProxyAdmin proxyAdmin, address impl, address[6] memory proxys) internal {
        address l1ERC721BridgeProxy = proxys[5];

        // TODO: Built L2 uses L1ChugSplashProxy and requires special handling.
        proxyAdmin.upgrade({ _proxy: payable(l1ERC721BridgeProxy), _implementation: impl });
    }

    /// @notice Initialize the L1CrossDomainMessenger
    function _initializeL1CrossDomainMessenger(
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    )
        internal
    {
        address l1CrossDomainMessengerProxy = proxys[3];

        // TODO: Built L2 uses OVM_L1CrossDomainMessengerProxy and requires special handling.
        proxyAdmin.upgradeAndCall({
            _proxy: payable(l1CrossDomainMessengerProxy),
            _implementation: impl,
            _data: BUILD_L1CROSS_DOMAIN_MESSENGER.initializeData()
        });
    }

    /// @notice Initialize the L2OutputOracle
    function _initializeL2OutputOracle(
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    )
        internal
    {
        address l2OutputOracleProxy = proxys[1];

        proxyAdmin.upgradeAndCall({
            _proxy: payable(l2OutputOracleProxy),
            _implementation: impl,
            _data: BUILD_L2OUTPUT_ORACLE.initializeData({
                _startingBlockNumber: _cfg.l2OutputOracleStartingBlockNumber,
                _startingTimestamp: _cfg.l2OutputOracleStartingTimestamp
            })
        });
    }

    /// @notice Initialize the OptimismPortal
    function _initializeOptimismPortal(ProxyAdmin proxyAdmin, address impl, address[6] memory proxys) internal {
        address optimismPortalProxy = proxys[0];

        proxyAdmin.upgradeAndCall({
            _proxy: payable(optimismPortalProxy),
            _implementation: impl,
            _data: BUILD_OPTIMISM_PORTAL.initializeData({ _paused: false })
        });
    }

    /// @notice Transfer ownership of the ProxyAdmin contract to the final system owner
    function _transferProxyAdminOwnership(BuildConfig calldata _cfg, ProxyAdmin proxyAdmin) internal {
        address owner = proxyAdmin.owner();
        address finalSystemOwner = _cfg.finalSystemOwner;
        if (owner != finalSystemOwner) {
            proxyAdmin.transferOwnership(finalSystemOwner);
        }
    }
}
