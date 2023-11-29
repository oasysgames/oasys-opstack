// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ProxyAdmin } from "../../universal/ProxyAdmin.sol";
import { Proxy } from "../../universal/Proxy.sol";
import { OptimismPortal } from "../../L1/OptimismPortal.sol";
import { L1StandardBridge } from "../../L1/L1StandardBridge.sol";
import { L1ERC721Bridge } from "../../L1/L1ERC721Bridge.sol";
import { L1CrossDomainMessenger } from "../../L1/L1CrossDomainMessenger.sol";
import { L2OutputOracle } from "../../L1/L2OutputOracle.sol";
// import { L2OutputOracle } from "../L1/OasysL2OutputOracle.sol";
import { SystemConfig } from "../../L1/SystemConfig.sol";
import { Semver } from "../../universal/Semver.sol";
import { Constants } from "../../libraries/Constants.sol";
import { IBuild_Common } from "./interfaces/IBuild_Common.sol";
import { IBuild_L2OutputOracle } from "./interfaces/IBuild_L2OutputOracle.sol";
import { IL1BuildAgentV1 } from "./interfaces/IL1BuildAgentV1.sol";

/// @notice The 2nd version of L1BuildAgent
///         Regarding the build step, referred to the build script of Opstack
///         Ref: https://github.com/ethereum-optimism/optimism/blob/v1.1.6/packages/contracts-bedrock/scripts/Deploy.s.sol#L67
contract L1BuildAgent is Semver {
    /// @notice These hold the bytecodes of the contracts that are deployed by this contract.
    ///         Separate to avoid hitting the contract size limit.
    IBuild_L2OutputOracle public immutable BUILD_L2OUTPUT_ORACLE;
    IBuild_Common public immutable BUILD_OPTIMISM_PORTAL;
    IBuild_Common public immutable BUILD_L1CROSS_DOMAIN_MESSENGER;
    IBuild_Common public immutable BUILD_SYSTEM_CONFIG;
    IBuild_Common public immutable BUILD_L1_STANDARD_BRIDGE;
    IBuild_Common public immutable _BUILD_L1_ERC721_BRIDGE;

    /// @notice The address of the L1BuildAgentV1
    ///         Used to ensure that the chainId is unique and not duplicated.
    IL1BuildAgentV1 public immutable L1_BUILD_AGENT_V1;

    /// @notice The map of chainId => SystemConfig contract address
    ///         The SystemConfig holds the addresses of the other contracts, So agent don't manage it
    mapping(uint256 => address) public chainSystemConfig;

    /// @notice List of chainIds that have been deployed, Return all chainIds at once
    ///         The size of the array isn't a concern; the limitation lies in the gas cost and comuputaion time.
    ///         Ref: https://betterprogramming.pub/issues-of-returning-arrays-of-dynamic-size-in-solidity-smart-contracts-dd1e54424235
    uint256[] public chainIds;

    /// @notice The base number to generate batch inbox address
    uint160 public constant BASE_BATCH_INBOX_ADDRESS =
        uint160(0xfF0000000000000000000000000000000000FF00);

    /// @notice The create2 salt used for deployment of the contract implementations.
    ///         Using this helps to reduce duplicated deployment costs
    bytes32 public constant SALT = keccak256("implementation contract salt");

    /// @notice Event emitted when the L1 contract set is deployed
    event Deployed(
        address owner,
        address proxyAdmin,
        address[6] proxys,
        address[6] impls,
        address batchInbox
    );

    constructor(
        IBuild_L2OutputOracle _bOutputOracle,
        IBuild_Common _bOptimismPortal,
        IBuild_Common _bL1CrossDomainMessenger,
        IBuild_Common _bSystemConfig,
        IBuild_Common _bL1StandardBridg,
        IBuild_Common _bL1ERC721Bridge,
        IL1BuildAgentV1 _buildAgentV1
    ) Semver(2, 0, 0) {
        BUILD_L2OUTPUT_ORACLE = _bOutputOracle;
        BUILD_OPTIMISM_PORTAL = _bOptimismPortal;
        BUILD_L1CROSS_DOMAIN_MESSENGER = _bL1CrossDomainMessenger;
        BUILD_SYSTEM_CONFIG = _bSystemConfig;
        BUILD_L1_STANDARD_BRIDGE = _bL1StandardBridg;
        _BUILD_L1_ERC721_BRIDGE = _bL1ERC721Bridge;

        L1_BUILD_AGENT_V1 = _buildAgentV1;
    }

    struct BuildConfig {
        // The owner of L1 contract set. Any L1 contract that is ownable has this account set as its owner
        // Value: depending on each verse
        address finalSystemOwner;
        // The address of proposer. this address is recorded in L2OutputOracle contract as `proposer`
        // Value: depening of each verse
        address l2OutputOracleProposer;
        // The address of challenger. this address is recorded in L2OutputOracle contract as `challenger`
        // Value: depening of each verse
        address l2OutputOracleChallenger;
        // The address of the l2 transaction batch sender. This address is recorded in SystemConfig contract.
        // Value: depending on each verse
        address batchSenderAddress;
        // the block time of l2 chain
        // Value: 2s
        uint256 l2BlockTime;
        // Used for calculate the next checkpoint block number, in Opstack case, 120 is set in testnet. 2s(default l2 block time) * 120 = 240s. submit l2 root every 240s. it means l2->l1 withdrawal will be available every 240s.
        // Value: 120
        uint256 l2OutputOracleSubmissionInterval;
        // The amount of time that must pass for an output proposal to be considered canonical. Once this time past, anybody can delete l2 root.
        // Value: 7 days
        uint256 finalizationPeriodSeconds;
        /// ------ considering to remove the following parameters ------
        uint256 l2OutputOracleStartingBlockNumber;
        uint256 l2OutputOracleStartingTimestamp;
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
        address[6] memory impls = _deployImplementations(_cfg);

        // compute the batch inbox address from chainId
        // L2 tx bathch is sent to this address
        address batchInbox = computeInboxAddress(_chainId);

        emit Deployed(_cfg.finalSystemOwner, address(proxyAdmin), proxys, impls, batchInbox);

        // initialize each contracts by calling `initialize` functions through proxys
        _initializeSystemConfig(_cfg, proxyAdmin, impls[2], proxys, batchInbox);
        _initializeL1StandardBridge(proxyAdmin, impls[4], proxys);
        _initializeL1ERC721Bridge(proxyAdmin, impls[5], proxys);
        _initializeL1CrossDomainMessenger(proxyAdmin, impls[3], proxys);
        _initializeL2OutputOracle(_cfg, proxyAdmin, impls[1], proxys);
        _initializeOptimismPortal(_cfg, proxyAdmin, impls[0], proxys);

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
        if (L1_BUILD_AGENT_V1 == IL1BuildAgentV1(address(0))) {
            return _isInternallyUniqueChainId(_chainId);
        }
        return
            _isInternallyUniqueChainId(_chainId) &&
            L1_BUILD_AGENT_V1.getAddressManager(_chainId) == address(0);
    }

    function _isInternallyUniqueChainId(uint256 _chainId) internal view returns (bool) {
        return chainSystemConfig[_chainId] == address(0);
    }

    function _deployProxies(
        address admin
    ) internal returns (ProxyAdmin proxyAdmin, address[6] memory proxys) {
        proxyAdmin = new ProxyAdmin({ _owner: admin });
        proxys[0] = _deployProxy(address(proxyAdmin)); // OptimismPortalProxy
        proxys[1] = _deployProxy(address(proxyAdmin)); // L2OutputOracleProxy
        proxys[2] = _deployProxy(address(proxyAdmin)); // SystemConfigProxy
        proxys[3] = _deployProxy(address(proxyAdmin)); // L1CrossDomainMessengerProxy
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
        BuildConfig calldata _cfg
    ) internal returns (address[6] memory impls) {
        impls[0] = _deployImplementation(BUILD_OPTIMISM_PORTAL.deployBytecode());
        impls[1] = _deployImplementation(
            BUILD_L2OUTPUT_ORACLE.deployBytecode(
                _cfg.l2OutputOracleSubmissionInterval,
                _cfg.l2BlockTime,
                _cfg.finalizationPeriodSeconds
            )
        );
        impls[2] = _deployImplementation(BUILD_SYSTEM_CONFIG.deployBytecode());
        impls[3] = _deployImplementation(BUILD_L1CROSS_DOMAIN_MESSENGER.deployBytecode());
        impls[4] = _deployImplementation(_BUILD_L1_ERC721_BRIDGE.deployBytecode());
        impls[5] = _deployImplementation(_BUILD_L1_ERC721_BRIDGE.deployBytecode());
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
        address[6] memory proxys,
        address batchInbox
    ) internal {
        SystemConfig.Addresses memory sysAddrs = SystemConfig.Addresses({
            l1CrossDomainMessenger: proxys[3], // L1CrossDomainMessengerProxy
            l1ERC721Bridge: proxys[5], // L1ERC721BridgeProxy,
            l1StandardBridge: proxys[4], // L1StandardBridgeProxy,
            l2OutputOracle: proxys[1], // L2OutputOracleProxy,
            optimismPortal: proxys[0], // OptimismPortalProxy,
            optimismMintableERC20Factory: address(0) // OptimismMintableERC20FactoryProxy
        });

        proxyAdmin.upgradeAndCall({
            _proxy: payable(proxys[2]),
            _implementation: impl,
            _data: abi.encodeCall(
                SystemConfig.initialize,
                (
                    _cfg.finalSystemOwner,
                    2100, // gasPriceOracleOverhead
                    1000_000, // gasPriceOracleScalar
                    bytes32(uint256(uint160(_cfg.batchSenderAddress))),
                    30_000_000, // l2GenesisBlockGasLimit
                    // This is originally `p2pSequencerAddress` which sign the block for p2p propagation
                    // Don't distinguish between sequencer and p2pSequencerAddress(=unsafeBlockSigner)
                    _cfg.l2OutputOracleProposer,
                    Constants.DEFAULT_RESOURCE_CONFIG(),
                    block.number, // systemConfigStartBlock
                    batchInbox,
                    sysAddrs
                )
            )
        });
    }

    /// @notice Initialize the L1StandardBridge
    function _initializeL1StandardBridge(
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    ) internal {
        address l1StandardBridgeProxy = proxys[4];
        // proxyAdmin.setProxyType(l1StandardBridgeProxy, ProxyAdmin.ProxyType.ERC1967);
        proxyAdmin.upgradeAndCall({
            _proxy: payable(l1StandardBridgeProxy),
            _implementation: impl,
            _data: abi.encodeCall(L1StandardBridge.initialize, (L1CrossDomainMessenger(proxys[3])))
        });
    }

    /// @notice Initialize the L1ERC721Bridge
    function _initializeL1ERC721Bridge(
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    ) internal {
        address l1ERC721BridgeProxy = proxys[5];
        proxyAdmin.upgradeAndCall({
            _proxy: payable(l1ERC721BridgeProxy),
            _implementation: impl,
            _data: abi.encodeCall(L1ERC721Bridge.initialize, (L1CrossDomainMessenger(proxys[3])))
        });
    }

    /// @notice Initialize the L1CrossDomainMessenger
    function _initializeL1CrossDomainMessenger(
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    ) internal {
        address l1CrossDomainMessengerProxy = proxys[3];
        // proxyAdmin.setProxyType(l1CrossDomainMessengerProxy, ProxyAdmin.ProxyType.RESOLVED);
        // string memory contractName = "OVM_L1CrossDomainMessenger";
        // string memory implName = proxyAdmin.implementationName(impl);
        // proxyAdmin.setImplementationName(l1CrossDomainMessengerProxy, contractName);

        proxyAdmin.upgradeAndCall({
            _proxy: payable(l1CrossDomainMessengerProxy),
            _implementation: impl,
            _data: abi.encodeCall(
                L1CrossDomainMessenger.initialize,
                (OptimismPortal(payable(proxys[0])))
            )
        });
    }

    /// @notice Initialize the L2OutputOracle
    function _initializeL2OutputOracle(
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    ) internal {
        address l2OutputOracleProxy = proxys[1];

        proxyAdmin.upgradeAndCall({
            _proxy: payable(l2OutputOracleProxy),
            _implementation: impl,
            _data: abi.encodeCall(
                L2OutputOracle.initialize,
                (
                    _cfg.l2OutputOracleStartingBlockNumber,
                    _cfg.l2OutputOracleStartingTimestamp,
                    _cfg.l2OutputOracleProposer,
                    _cfg.l2OutputOracleChallenger
                )
            )
        });
    }

    /// @notice Initialize the OptimismPortal
    function _initializeOptimismPortal(
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl,
        address[6] memory proxys
    ) internal {
        address optimismPortalProxy = proxys[0];

        proxyAdmin.upgradeAndCall({
            _proxy: payable(optimismPortalProxy),
            _implementation: impl,
            _data: abi.encodeCall(
                OptimismPortal.initialize,
                (
                    L2OutputOracle(proxys[1]),
                    // This is originally `portalGuardian` which has priviledge to pause the `OptimismPortal`
                    // Don't distinguish between `portalGuardian` and `finalSystemOwner`
                    _cfg.finalSystemOwner,
                    SystemConfig(proxys[2]),
                    false
                )
            )
        });
    }

    /// @notice Transfer ownership of the ProxyAdmin contract to the final system owner
    function _transferProxyAdminOwnership(
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin
    ) internal {
        address owner = proxyAdmin.owner();
        address finalSystemOwner = _cfg.finalSystemOwner;
        if (owner != finalSystemOwner) {
            proxyAdmin.transferOwnership(finalSystemOwner);
        }
    }
}
