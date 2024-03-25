// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { L1ChugSplashProxy } from "src/legacy/L1ChugSplashProxy.sol";
import { ResolvedDelegateProxy } from "src/legacy/ResolvedDelegateProxy.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { ProtocolVersion } from "src/L1/ProtocolVersions.sol";
import { ISemver } from "src/universal/ISemver.sol";
import { Constants } from "src/libraries/Constants.sol";
import { L2PredeployAddresses } from "src/oasys/L2/L2PredeployAddresses.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";
import { IBuildProxy } from "src/oasys/L1/build/interfaces/IBuildProxy.sol";
import { IBuildOasysL2OutputOracle } from "src/oasys/L1/build/interfaces/IBuildOasysL2OutputOracle.sol";
import { IBuildOasysPortal } from "src/oasys/L1/build/interfaces/IBuildOasysPortal.sol";
import { IBuildL1CrossDomainMessenger } from "src/oasys/L1/build/interfaces/IBuildL1CrossDomainMessenger.sol";
import { IBuildSystemConfig } from "src/oasys/L1/build/interfaces/IBuildSystemConfig.sol";
import { IBuildL1StandardBridge } from "src/oasys/L1/build/interfaces/IBuildL1StandardBridge.sol";
import { IBuildL1ERC721Bridge } from "src/oasys/L1/build/interfaces/IBuildL1ERC721Bridge.sol";
import { IBuildProtocolVersions } from "src/oasys/L1/build/interfaces/IBuildProtocolVersions.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";
import { IOasysL2OutputOracleVerifier } from "src/oasys/L1/interfaces/IOasysL2OutputOracleVerifier.sol";
import { PortalSender } from "src/oasys/L1/build/PortalSender.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";

/// @notice The 2nd version of L1BuildAgent
///         Regarding the build step, referred to the build script of Opstack
///         Ref:
/// https://github.com/ethereum-optimism/optimism/blob/v1.1.6/packages/contracts-bedrock/scripts/Deploy.s.sol#L67
contract L1BuildAgent is IL1BuildAgent, ISemver {
    /// @notice These hold the bytecodes of the contracts that are deployed by this contract.
    ///         Separate to avoid hitting the contract size limit.
    IBuildProxy public immutable BUILD_PROXY;
    IBuildOasysL2OutputOracle public immutable BUILD_OASYS_L2OO;
    IBuildOasysPortal public immutable BUILD_OASYS_PORTAL;
    IBuildL1CrossDomainMessenger public immutable BUILD_L1CROSS_DOMAIN_MESSENGER;
    IBuildSystemConfig public immutable BUILD_SYSTEM_CONFIG;
    IBuildL1StandardBridge public immutable BUILD_L1_STANDARD_BRIDGE;
    IBuildL1ERC721Bridge public immutable BUILD_L1_ERC721_BRIDGE;
    IBuildProtocolVersions public immutable BUILD_PROTOCOL_VERSIONS;
    IOasysL2OutputOracleVerifier public immutable L2OO_VERIFIER;

    /// @notice Referred to verify required deposit amount to build a Verse
    IL1BuildDeposit public immutable L1_BUILD_DEPOSIT;

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

    /// @notice The map of chainId => builder
    mapping(uint256 => address) public builders;

    /// @notice The map of chainId => BuiltAddressList
    mapping(uint256 => BuiltAddressList) public builtLists;

    /// @notice List of chainIds that have been deployed, Return all chainIds at once
    ///         The size of the array isn't a concern; the limitation lies in the gas cost and comuputaion time.
    ///         Ref:
    /// https://betterprogramming.pub/issues-of-returning-arrays-of-dynamic-size-in-solidity-smart-contracts-dd1e54424235
    uint256[] public chainIds;

    constructor(
        IBuildProxy _bProxy,
        IBuildOasysL2OutputOracle _bOasysL2OO,
        IBuildOasysPortal _bOasysPortal,
        IBuildL1CrossDomainMessenger _bL1CrossDomainMessenger,
        IBuildSystemConfig _bSystemConfig,
        IBuildL1StandardBridge _bL1StandardBridg,
        IBuildL1ERC721Bridge _bL1ERC721Bridge,
        IBuildProtocolVersions _bProtocolVersions,
        IL1BuildDeposit _l1BuildDeposit,
        ILegacyL1BuildAgent _legacyL1BuildAgent,
        IOasysL2OutputOracleVerifier _l2ooVerifier
    ) {
        BUILD_PROXY = _bProxy;
        BUILD_OASYS_L2OO = _bOasysL2OO;
        BUILD_OASYS_PORTAL = _bOasysPortal;
        BUILD_L1CROSS_DOMAIN_MESSENGER = _bL1CrossDomainMessenger;
        BUILD_SYSTEM_CONFIG = _bSystemConfig;
        BUILD_L1_STANDARD_BRIDGE = _bL1StandardBridg;
        BUILD_L1_ERC721_BRIDGE = _bL1ERC721Bridge;
        BUILD_PROTOCOL_VERSIONS = _bProtocolVersions;

        L1_BUILD_DEPOSIT = _l1BuildDeposit;
        LEGACY_L1_BUILD_AGENT = _legacyL1BuildAgent;
        L2OO_VERIFIER = _l2ooVerifier;
    }

    /// @notice Deploy the L1 contract set to build Verse, This is th main function.
    /// @param _chainId The chainId of Verse
    /// @param _cfg The configuration of the L1 contract set
    function build(
        uint256 _chainId,
        BuildConfig calldata _cfg
    )
        external
        returns (BuiltAddressList memory, address[7] memory)
    {
        // Only the builder can build the L2
        // The builder is the person who deposits the required amount
        address builder = msg.sender;

        // Not require to be globally unique, as the pre built L2 needs to be upgraded
        require(_isInternallyUniqueChainId(_chainId), "L1BuildAgent: already deployed");
        if (_requiresDepositCheck(_chainId)) {
            require(
                L1_BUILD_DEPOSIT.getDepositTotal(builder) >= L1_BUILD_DEPOSIT.requiredAmount(),
                "deposit amount shortage"
            );
        }

        // build the deposit.
        // Mark this builder as built.
        L1_BUILD_DEPOSIT.build(builder);

        // register the builder
        // Mark this chainId as built
        builders[_chainId] = builder;

        // check if the L2 is upgrading the existing L2
        // If so, the existing address manager is set to the legacyAddressManager
        // otherwise, legacyAddressManager is empty
        bool isUpgradingExistingL2 = _cfg.legacyAddressManager != address(0);

        // temporarily set the admin to this contract
        // transfer ownership to the final system owner at the end of building
        address admin = address(this);

        // deploy proxy contracts for each verse
        ProxyAdmin proxyAdmin = _deployProxies(_chainId, admin, _cfg.legacyAddressManager);

        if (isUpgradingExistingL2) {
            // Pause the legacy L1CrossDomainMessenger
            _pauseLegacyL1CrossDomainMessenger(_cfg.legacyAddressManager);
            // Set the address of the AddressManager.
            proxyAdmin.setAddressManager(AddressManager(_cfg.legacyAddressManager));
            require(proxyAdmin.addressManager() == AddressManager(_cfg.legacyAddressManager));
            // transfer ownership of the address manager to the ProxyAdmin
            AddressManager(_cfg.legacyAddressManager).transferOwnership(address(proxyAdmin));
        }

        // don't deploy the implementation contracts every time
        // to save gas, reuse the same implementation contract for each proxy
        address[7] memory impls = _deployImplementations(_chainId, _cfg);

        emit Deployed(_chainId, _cfg.finalSystemOwner, _cfg.legacyAddressManager, builtLists[_chainId], impls);

        // append the chainId to the list
        chainIds.push(_chainId);

        // initialize each contracts by calling `initialize` functions through proxys
        _initializeSystemConfig(_chainId, _cfg, proxyAdmin, impls[2]);
        _initializeL1StandardBridge(_chainId, proxyAdmin, impls[4], isUpgradingExistingL2);
        _initializeL1ERC721Bridge(_chainId, proxyAdmin, impls[5], isUpgradingExistingL2);
        _initializeL1CrossDomainMessenger(_chainId, proxyAdmin, impls[3], isUpgradingExistingL2);
        _initializeOasysL2OutputOracle(_chainId, _cfg, proxyAdmin, impls[1]);
        _initializeOasysPortal(_chainId, proxyAdmin, impls[0]);
        _initializeProtocolVersions(_chainId, _cfg, proxyAdmin, impls[6]);

        // transfer ownership of the proxy admin to the final system owner
        _transferProxyAdminOwnership(_cfg, proxyAdmin);

        return (builtLists[_chainId], impls);
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
        return builders[_chainId] == address(0);
    }

    function _requiresDepositCheck(uint256 _chainId) internal view returns (bool) {
        // always require deposit check if no legacy build agent
        if (LEGACY_L1_BUILD_AGENT == ILegacyL1BuildAgent(address(0))) {
            return true;
        }
        // skip deposit check if the chainId is already deployed by the legacy build agent
        // In other words, skip deposit check in the case of L2 upgrade
        if (LEGACY_L1_BUILD_AGENT.getAddressManager(_chainId) != address(0)) {
            return false;
        }
        // require deposit check if the chainId is not deployed by the legacy build agent
        return true;
    }

    function _deployProxies(
        uint256 _chainId,
        address admin,
        address addressManager
    )
        internal
        returns (ProxyAdmin proxyAdmin)
    {
        proxyAdmin = BUILD_PROXY.deployProxyAdmin({ owner: admin });

        // register built addresses to the builtLists
        builtLists[_chainId].proxyAdmin = address(proxyAdmin);
        builtLists[_chainId].oasysPortal = _deployProxy(address(proxyAdmin));
        builtLists[_chainId].oasysL2OutputOracle = _deployProxy(address(proxyAdmin));
        builtLists[_chainId].systemConfig = _deployProxy(address(proxyAdmin));
        builtLists[_chainId].l1CrossDomainMessenger = _deployL1CrossDomainMessengerProxy(address(proxyAdmin), addressManager);
        builtLists[_chainId].l1StandardBridge = _deployL1StandardBridgeProxy(address(proxyAdmin), addressManager);
        builtLists[_chainId].l1ERC721Bridge = _deployL1ERC721BridgeProxy(address(proxyAdmin), addressManager);
        builtLists[_chainId].protocolVersions = _deployProxy(address(proxyAdmin));

        // compute the batch inbox address from chainId
        // L2 tx bathch is sent to this address
        builtLists[_chainId].batchInbox = computeInboxAddress(_chainId);
    }

    /// @notice Deploy the Proxy
    function _deployProxy(address admin) internal returns (address addr) {
        addr = address(BUILD_PROXY.deployERC1967Proxy({ admin: admin }));
    }

    /// @notice Deploy the L1CrossDomainMessengerProxy using a ResolvedDelegateProxy
    function _deployL1CrossDomainMessengerProxy(address proxyAdmin, address addressManager) internal returns (address addr) {
        if (addressManager != address(0)) {
            // upgrading existing L2
            // Don't deply proxy, as the existing L2 already has the proxy(RelolvedDelegateProxy)
            string memory contractName = "OVM_L1CrossDomainMessenger";
            addr = AddressManager(addressManager).getAddress(contractName);
            require(addr != address(0), "L1BuildAgent: failed to find L1CrossDomainMessengerProxy from AddressManager");
            // Trasfer ownership to ProxyAdmin
            // ResolvedDelegateProxy(payable(addr)).setOwner(address(proxyAdmin));
        } else {
            addr = _deployProxy(address(proxyAdmin));
        }
    }

    function _deployL1StandardBridgeProxy(address proxyAdmin, address addressManager) internal returns (address addr) {
        if (addressManager != address(0)) {
            // upgrading existing L2
            // Don't deply proxy, as the existing L2 already has the proxy(RelolvedDelegateProxy)
            string memory contractName = "Proxy__OVM_L1StandardBridge";
            addr = AddressManager(addressManager).getAddress(contractName);
            require(addr != address(0), "L1BuildAgent: failed to find L1StandardBridgeProxy from AddressManager");
            // Trasfer ownership to ProxyAdmin
            L1ChugSplashProxy(payable(addr)).setOwner(address(proxyAdmin));
        } else {
            addr = _deployProxy(address(proxyAdmin));
        }
    }

    function _deployL1ERC721BridgeProxy(address proxyAdmin, address addressManager) internal returns (address addr) {
        if (addressManager != address(0)) {
            // upgrading existing L2
            // Don't deply proxy, as the existing L2 already has the proxy(RelolvedDelegateProxy)
            string memory contractName = "Proxy__OVM_L1ERC721Bridge";
            addr = AddressManager(addressManager).getAddress(contractName);
            require(addr != address(0), "L1BuildAgent: failed to find L1ERC721BridgeProxy from AddressManager");
            // Trasfer ownership to ProxyAdmin
            L1ChugSplashProxy(payable(addr)).setOwner(address(proxyAdmin));
        } else {
            addr = _deployProxy(address(proxyAdmin));
        }
    }

    /// @notice Deploy all of the implementations
    function _deployImplementations(
        uint256 _chainId,
        BuildConfig calldata _cfg
    )
        internal
        returns (address[7] memory impls)
    {
        impls[0] = _deployImplementation(
            BUILD_OASYS_PORTAL.deployBytecode({
                _l2Oracle: builtLists[_chainId].oasysL2OutputOracle,
                _guardian: _cfg.finalSystemOwner,
                _systemConfig: builtLists[_chainId].systemConfig
             })
        );

        address _challenger = _cfg.l2OutputOracleChallenger;
        if (_challenger == address(0)) {
            _challenger = _cfg.finalSystemOwner;
        }
        impls[1] = _deployImplementation(
            BUILD_OASYS_L2OO.deployBytecode({
                _submissionInterval: _cfg.l2OutputOracleSubmissionInterval,
                _l2BlockTime: _cfg.l2BlockTime,
                _proposer: _cfg.l2OutputOracleProposer,
                _challenger: _challenger,
                _finalizationPeriodSeconds: _cfg.finalizationPeriodSeconds,
                _verifier: address(L2OO_VERIFIER)
            })
        );

        impls[2] = _deployImplementation(BUILD_SYSTEM_CONFIG.deployBytecode());

        impls[3] = _deployImplementation(
            BUILD_L1CROSS_DOMAIN_MESSENGER.deployBytecode({
                _portal: payable(builtLists[_chainId].oasysPortal) // OasysPortalProxy
             })
        );

        impls[4] = _deployImplementation(
            BUILD_L1_STANDARD_BRIDGE.deployBytecode({
                _messenger: payable(builtLists[_chainId].l1CrossDomainMessenger) // L1CrossDomainMessengerProxy
             })
        );

        impls[5] = _deployImplementation(
            BUILD_L1_ERC721_BRIDGE.deployBytecode({
                _messenger: builtLists[_chainId].l1CrossDomainMessenger, // L1CrossDomainMessengerProxy
                _otherBridge: L2PredeployAddresses.L2_ERC721_BRIDGE
            })
        );

        impls[6] = _deployImplementation(BUILD_PROTOCOL_VERSIONS.deployBytecode());
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
        uint256 _chainId,
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl
    )
        internal
    {
        address systemConfigProxy = builtLists[_chainId].systemConfig;

        proxyAdmin.upgradeAndCall({
            _proxy: payable(systemConfigProxy),
            _implementation: impl,
            _data: BUILD_SYSTEM_CONFIG.initializeData({
                _owner: _cfg.finalSystemOwner,
                _batcherHash: bytes32(uint256(uint160(_cfg.batchSenderAddress))),
                _config: Constants.DEFAULT_RESOURCE_CONFIG(),
                // unsafeBlockSigner is same as p2pSequencerAddress
                // This address signs the unsafe block. The signed unsafe block is broadcasted to other p2p peers.
                _unsafeBlockSigner: _cfg.p2pSequencerAddress,
                // gasPriceOracleOverhead
                // The rollup gas of L2 txs batch is calculated by the size of L2 data. This overhead is added to it.
                // The value bellow is the same as the value of the Opstack Mainnet
                _overhead: 188,
                // gasPriceOracleScalar
                // This scalar multiply the rollup gas of L2 txs batch. right after, the result is devided by 1_000_000
                // As a result, the gas is 684_000/1_000_000 of comupted value. unknown why this is needed.
                // The value bellow is the same as the value of the Opstack Mainnet
                _scalar: 684_000,
                _gasLimit: _cfg.l2GasLimit
            })
        });
    }

    /// @notice Initialize the L1StandardBridge
    function _initializeL1StandardBridge(
        uint256 _chainId,
        ProxyAdmin proxyAdmin,
        address impl,
        bool isUpgradingExistingL2
    ) internal {
        address l1StandardBridgeProxy = builtLists[_chainId].l1StandardBridge;

        if (isUpgradingExistingL2) {
            // The proxy of Legacy L2 is L1ChugSplashProxy, so need to set type
            proxyAdmin.setProxyType(l1StandardBridgeProxy, ProxyAdmin.ProxyType.CHUGSPLASH);
            require(uint256(proxyAdmin.proxyType(l1StandardBridgeProxy)) == uint256(ProxyAdmin.ProxyType.CHUGSPLASH));

            // Transfer ETH from the L1StandardBridge to the OptimismPortal.
            PortalSender portalSender = new PortalSender(OptimismPortal(payable(builtLists[_chainId].oasysPortal)));
            proxyAdmin.upgradeAndCall(
                payable(l1StandardBridgeProxy),
                address(portalSender),
                abi.encodeCall(PortalSender.donate, ())
            );
        }

        proxyAdmin.upgrade({ _proxy: payable(l1StandardBridgeProxy), _implementation: impl });
    }

    /// @notice Initialize the L1ERC721Bridge
    function _initializeL1ERC721Bridge(
        uint256 _chainId,
        ProxyAdmin proxyAdmin,
        address impl,
        bool isUpgradingExistingL2
    ) internal {
        address l1ERC721BridgeProxy = builtLists[_chainId].l1ERC721Bridge;

        if (isUpgradingExistingL2) {
            // The proxy of Legacy L2 is L1ChugSplashProxy, so need to set type
            proxyAdmin.setProxyType(l1ERC721BridgeProxy, ProxyAdmin.ProxyType.CHUGSPLASH);
            require(uint256(proxyAdmin.proxyType(l1ERC721BridgeProxy)) == uint256(ProxyAdmin.ProxyType.CHUGSPLASH));
        }

        proxyAdmin.upgrade({ _proxy: payable(l1ERC721BridgeProxy), _implementation: impl });
    }

    /// @notice Initialize the L1CrossDomainMessenger
    function _initializeL1CrossDomainMessenger(
        uint256 _chainId,
        ProxyAdmin proxyAdmin,
        address impl,
        bool isUpgradingExistingL2
    )
        internal
    {
        address l1CrossDomainMessengerProxy = builtLists[_chainId].l1CrossDomainMessenger;

        if (isUpgradingExistingL2) {
            // The proxy of Legacy L2 is ResolvedDelegateProxy, so need to set type and implementation name
            // Set proxy type to RESOLVED
            proxyAdmin.setProxyType(l1CrossDomainMessengerProxy, ProxyAdmin.ProxyType.RESOLVED);
            require(uint256(proxyAdmin.proxyType(l1CrossDomainMessengerProxy)) == uint256(ProxyAdmin.ProxyType.RESOLVED));
            // Set the implementation name to OVM_L1CrossDomainMessenger
            string memory contractName = "OVM_L1CrossDomainMessenger";
            proxyAdmin.setImplementationName(l1CrossDomainMessengerProxy, contractName);
            require(
                keccak256(bytes(proxyAdmin.implementationName(l1CrossDomainMessengerProxy)))
                    == keccak256(bytes(contractName))
            );
        }

        proxyAdmin.upgradeAndCall({
            _proxy: payable(l1CrossDomainMessengerProxy),
            _implementation: impl,
            _data: BUILD_L1CROSS_DOMAIN_MESSENGER.initializeData()
        });
    }

    /// @notice Initialize the OasysL2OutputOracle
    function _initializeOasysL2OutputOracle(
        uint256 _chainId,
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl
    )
        internal
    {
        address l2OutputOracleProxy = builtLists[_chainId].oasysL2OutputOracle;

        proxyAdmin.upgradeAndCall({
            _proxy: payable(l2OutputOracleProxy),
            _implementation: impl,
            _data: BUILD_OASYS_L2OO.initializeData({
                _startingBlockNumber: _cfg.l2OutputOracleStartingBlockNumber,
                _startingTimestamp: _cfg.l2OutputOracleStartingTimestamp
            })
        });
    }

    /// @notice Initialize the OasysPortal
    function _initializeOasysPortal(uint256 _chainId, ProxyAdmin proxyAdmin, address impl) internal {
        address oasysPortalProxy = builtLists[_chainId].oasysPortal;

        proxyAdmin.upgradeAndCall({
            _proxy: payable(oasysPortalProxy),
            _implementation: impl,
            _data: BUILD_OASYS_PORTAL.initializeData({ _paused: false })
        });
    }

    function _initializeProtocolVersions(
        uint256 _chainId,
        BuildConfig calldata _cfg,
        ProxyAdmin proxyAdmin,
        address impl
    )
        internal
    {
        address protocolVersionsProxy = builtLists[_chainId].protocolVersions;

        uint256 requiredProtocolVersion = uint256(0x0);
        uint256 recommendedProtocolVersion = uint256(0x0);

        proxyAdmin.upgradeAndCall({
            _proxy: payable(protocolVersionsProxy),
            _implementation: impl,
            _data: BUILD_PROTOCOL_VERSIONS.initializeData({
                _owner: _cfg.finalSystemOwner,
                _required: ProtocolVersion.wrap(requiredProtocolVersion),
                _recommended: ProtocolVersion.wrap(recommendedProtocolVersion)
            })
        });
    }

    // Ref: step2, 3, and 4 of `SystemDictator`
    // https://github.com/oasysgames/oasys-opstack/blob/cd7c58349542f9f1ce9fd42c9054aeed1325e02c/packages/contracts-bedrock/contracts/deployment/SystemDictator.sol
    function _pauseLegacyL1CrossDomainMessenger(address addressManager) internal {
        // Temporarily brick the L1CrossDomainMessenger by setting its implementation address to
        // address(0) which will cause the ResolvedDelegateProxy to revert. Better than pausing
        // the L1CrossDomainMessenger via pause() because it can be easily reverted.
        AddressManager(addressManager).setAddress("OVM_L1CrossDomainMessenger", address(0));

        // Set the DTL shutoff block, which will tell the DTL to stop syncing new deposits from the
        // CanonicalTransactionChain. We do this by setting an address in the AddressManager
        // because the DTL already has a reference to the AddressManager and this way we don't also
        // need to give it a reference to the SystemDictator.
        AddressManager(addressManager).setAddress(
            "DTL_SHUTOFF_BLOCK",
            address(uint160(block.number))
        );

        // Remove all deprecated addresses from the AddressManager
        string[17] memory deprecated = [
            "OVM_CanonicalTransactionChain",
            "OVM_L2CrossDomainMessenger",
            "OVM_DecompressionPrecompileAddress",
            "OVM_Sequencer",
            "OVM_Proposer",
            "OVM_ChainStorageContainer-CTC-batches",
            "OVM_ChainStorageContainer-CTC-queue",
            "OVM_CanonicalTransactionChain",
            "OVM_StateCommitmentChain",
            "OVM_BondManager",
            "OVM_ExecutionManager",
            "OVM_FraudVerifier",
            "OVM_StateManagerFactory",
            "OVM_StateTransitionerFactory",
            "OVM_SafetyChecker",
            "OVM_L1MultiMessageRelayer",
            "BondManager"
        ];
        for (uint256 i = 0; i < deprecated.length; i++) {
            AddressManager(addressManager).setAddress(deprecated[i], address(0));
        }
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
