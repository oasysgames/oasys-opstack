// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";

import { Vm } from "forge-std/Vm.sol";
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { IPermissionedContractFactory } from "src/oasys/L1/interfaces/IPermissionedContractFactory.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { L1BuildAgent } from "src/oasys/L1/build/L1BuildAgent.sol";
import { L1BuildDeposit } from "src/oasys/L1/build/L1BuildDeposit.sol";

import { TestERC721 } from "test/mocks/TestERC721.sol";
import { Constants } from "src/libraries/Constants.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { ProtocolVersion } from "src/L1/ProtocolVersions.sol";
import { ProtocolVersions } from "src/L1/ProtocolVersions.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { OasysL2OutputOracleVerifier } from "src/oasys/L1/rollup/OasysL2OutputOracleVerifier.sol";

import { Path } from "scripts/oasys/L1/build/_path.sol";
import { Deploy } from "scripts/oasys/L1/build/Deploy.s.sol";

import { BuiltInContracts } from "test/setup/oasys/BuiltInContracts.sol";
import { MockLegacyL1BuildAgent } from "test/setup/oasys/MockLegacyL1BuildAgent.sol";
import { MockLegacyL1BuildDeposit } from "test/setup/oasys/MockLegacyL1BuildDeposit.sol";

contract SetupL1BuildAgent is Test {
    using stdJson for string;

    struct Deployment {
        // Build config
        uint256 chainId;
        AddressManager addressManager;
        IL1BuildAgent.BuildConfig buildCfg;
        // Deployed proxies
        OasysPortal portal;
        OasysL2OutputOracle l2Oracle;
        SystemConfig systemConfig;
        L1CrossDomainMessenger l1Messenger;
        L1StandardBridge l1ERC20Bridge;
        L1ERC721Bridge l1ERC721Bridge;
        ProtocolVersions protocolVersions;
        // Deployed implementations
        ProxyAdmin proxyAdmin;
        OasysPortal portalImpl;
        OasysL2OutputOracle l2OracleImpl;
        SystemConfig systemConfigImpl;
        L1CrossDomainMessenger l1MessengerImpl;
        L1StandardBridge l1ERC20BridgeImpl;
        L1ERC721Bridge l1ERC721BridgeImpl;
        ProtocolVersions protocolVersionsImpl;
        // Misc
        address batchInbox;
    }

    // Salt for Create2
    string private constant salt = "SetupL1BuildAgent";

    // Wallets
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address depositor = makeAddr("depositor");
    address builder = makeAddr("builder");
    address finalOwner = makeAddr("finalOwner");
    address proposer = makeAddr("proposer");
    address challenger = makeAddr("challenger");
    address batcher = makeAddr("batcher");
    address p2pSequencer = makeAddr("p2pSequencer");
    address relayer = makeAddr("messageRelayer");

    // Dependency contracts
    IPermissionedContractFactory permissionedFactory;
    OasysL2OutputOracleVerifier l2OracleVerifier;

    /// L1 Build contracts
    L1BuildAgent l1Agent;
    L1BuildDeposit l1Deposit;

    /// @dev Default deployment L2
    Deployment deployment;

    /// Legacy contracts
    MockLegacyL1BuildAgent legacyAgent;
    MockLegacyL1BuildDeposit legacyDeposit;

    function setUp() public virtual {
        _addBalanceToTestWallets();

        permissionedFactory = _deployPermissionedContractFactory(msg.sender);

        (l1Agent, l1Deposit, l2OracleVerifier) = _deployL1BuildContracts(permissionedFactory);
    }

    function _addBalanceToTestWallets() internal {
        address[8] memory wallets = [alice, bob, depositor, builder, finalOwner, proposer, challenger, batcher];
        for (uint8 i = 0; i < wallets.length; i++) {
            vm.deal(wallets[i], 10000 ether);
        }
    }

    /// @dev Deploy `PermissionedContractFactory`
    function _deployPermissionedContractFactory(address creator) internal returns (IPermissionedContractFactory) {
        address[] memory creators = new address[](1);
        creators[0] = creator;
        bytes memory bytecode = BuiltInContracts.PermissionedContractFactoryBytecode(new address[](0), creators);
        return IPermissionedContractFactory(Create2.deploy(0, keccak256(bytes(salt)), bytecode));
    }

    /// @dev Deploy L1 build contracts using `scripts/oasys/L1/build/Deploy.s.sol:Deploy`.
    function _deployL1BuildContracts(IPermissionedContractFactory factory)
        internal
        returns (L1BuildAgent, L1BuildDeposit, OasysL2OutputOracleVerifier)
    {
        legacyAgent = new MockLegacyL1BuildAgent();
        legacyDeposit = new MockLegacyL1BuildDeposit();

        vm.setEnv("SALT", salt);
        vm.setEnv("PERMISSIONED_FACTORY", vm.toString(address(factory)));
        vm.setEnv("LEGACY_AGENT", vm.toString(address(legacyAgent)));
        vm.setEnv("LEGACY_DEPOSIT", vm.toString(address(legacyDeposit)));

        string memory jsonPath = string.concat(Path.deployOutDir(), "/test.json");

        Deploy deploy = new Deploy();
        deploy.setUp();
        deploy.setDeployConfig(
            Deploy.DeployConfig({
                msgSender: msg.sender,
                deployOutDir: Path.deployOutDir(),
                deployLatestOutPath: jsonPath,
                deployRunOutPath: jsonPath
            })
        );
        deploy.run();

        string memory json = vm.readFile(jsonPath);
        return (
            L1BuildAgent(stdJson.readAddress(json, "$.L1BuildAgent")),
            L1BuildDeposit(stdJson.readAddress(json, "$.L1BuildDeposit")),
            OasysL2OutputOracleVerifier(stdJson.readAddress(json, "$.OasysL2OutputOracleVerifier"))
        );
    }

    /// @dev Run `L1BuildAgent.build()` method.
    function _runL1BuildAgent(
        uint256 chainId,
        address addressManager,
        IL1BuildAgent.BuildConfig memory cfg
    )
        internal
        returns (Deployment memory)
    {
        (IL1BuildAgent.BuiltAddressList memory results, address[7] memory impls) = l1Agent.build(chainId, cfg);

        return Deployment({
            // Build config
            chainId: chainId,
            addressManager: AddressManager(addressManager),
            buildCfg: cfg,
            // Deployed proxies
            portal: OasysPortal(payable(results.oasysPortal)),
            l2Oracle: OasysL2OutputOracle(results.oasysL2OutputOracle),
            systemConfig: SystemConfig(results.systemConfig),
            l1Messenger: L1CrossDomainMessenger(results.l1CrossDomainMessenger),
            l1ERC20Bridge: L1StandardBridge(payable(results.l1StandardBridge)),
            l1ERC721Bridge: L1ERC721Bridge(results.l1ERC721Bridge),
            protocolVersions: ProtocolVersions(results.protocolVersions),
            // Deployed implementations
            proxyAdmin: ProxyAdmin(results.proxyAdmin),
            portalImpl: OasysPortal(payable(impls[0])),
            l2OracleImpl: OasysL2OutputOracle(impls[1]),
            systemConfigImpl: SystemConfig(impls[2]),
            l1MessengerImpl: L1CrossDomainMessenger(impls[3]),
            l1ERC20BridgeImpl: L1StandardBridge(payable(impls[4])),
            l1ERC721BridgeImpl: L1ERC721Bridge(impls[5]),
            protocolVersionsImpl: ProtocolVersions(impls[6]),
            // Misc
            batchInbox: results.batchInbox
        });
    }
}

contract L1BuildAgentTestCommon is SetupL1BuildAgent {
    function test_batchInbox() external view {
        assert(deployment.batchInbox == 0xfF00000000000000000000000000000015B3FF00);
    }

    /**
     * @dev Tests for `ProxyAdmin`
     */
    function test_ProxyAdmin_owner() external view {
        assert(deployment.proxyAdmin.owner() == deployment.buildCfg.finalSystemOwner);
    }

    function test_ProxyAdmin_getProxyAdmin_SystemConfig_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.systemConfig))),
            address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_OasysPortal_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.portal))), address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_OasysL2OutputOracle_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.l2Oracle))), address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_L1CrossDomainMessenger_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.l1Messenger))),
            address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_L1StandardBridge_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.l1ERC20Bridge))),
            address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_L1ERC721Bridge_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.l1ERC721Bridge))),
            address(deployment.proxyAdmin)
        );
    }

    function test_ProxyAdmin_getProxyAdmin_ProtocolVersions_succeeds() external {
        assertEq(
            deployment.proxyAdmin.getProxyAdmin(payable(address(deployment.protocolVersions))),
            address(deployment.proxyAdmin)
        );
    }

    /**
     * @dev Tests for `OasysPortal`
     */
    function test_OasysPortal_initialized() external {
        vm.expectRevert("Initializable: contract is already initialized");
        deployment.portal.initialize(false);
    }

    function test_OasysPortal_L2_ORACLE() external view {
        assert(address(deployment.portal.L2_ORACLE()) == address(deployment.l2Oracle));
        assert(address(deployment.portalImpl.L2_ORACLE()) == address(deployment.l2Oracle));
    }

    function test_OasysPortal_SYSTEM_CONFIG() external view {
        assert(address(deployment.portal.SYSTEM_CONFIG()) == address(deployment.systemConfig));
        assert(address(deployment.portalImpl.SYSTEM_CONFIG()) == address(deployment.systemConfig));
    }

    function test_OasysPortal_GUARDIAN() external view {
        assert(address(deployment.portal.GUARDIAN()) == deployment.buildCfg.finalSystemOwner);
        assert(address(deployment.portalImpl.GUARDIAN()) == deployment.buildCfg.finalSystemOwner);
    }

    function test_OasysPortal_l2Sender() external view {
        assert(deployment.portal.l2Sender() == 0x000000000000000000000000000000000000dEaD);
        assert(deployment.portalImpl.l2Sender() == 0x000000000000000000000000000000000000dEaD);
    }

    function test_OasysPortal_paused() external view {
        assert(deployment.portal.paused() == false);
        assert(deployment.portalImpl.paused() == true);
    }

    function test_OasysPortal_messageRelayer() external view {
        assert(deployment.portal.messageRelayer() == address(deployment.buildCfg.messageRelayer));
        assert(deployment.portalImpl.messageRelayer() == address(0));
    }

    /**
     * @dev Tests for `OasysL2OutputOracle`
     */
    function test_OasysL2OutputOracle_initialized() external {
        vm.expectRevert("Initializable: contract is already initialized");
        deployment.l2Oracle.initialize(0, 0);
    }

    function test_OasysL2OutputOracle_SUBMISSION_INTERVAL() external view {
        assert(deployment.l2Oracle.SUBMISSION_INTERVAL() == deployment.buildCfg.l2OutputOracleSubmissionInterval);
        assert(deployment.l2OracleImpl.SUBMISSION_INTERVAL() == deployment.buildCfg.l2OutputOracleSubmissionInterval);
    }

    function test_OasysL2OutputOracle_L2_BLOCK_TIME() external view {
        assert(deployment.l2Oracle.L2_BLOCK_TIME() == deployment.buildCfg.l2BlockTime);
        assert(deployment.l2OracleImpl.L2_BLOCK_TIME() == deployment.buildCfg.l2BlockTime);
    }

    function test_OasysL2OutputOracle_CHALLENGER() external view {
        assert(deployment.l2Oracle.CHALLENGER() == deployment.buildCfg.l2OutputOracleChallenger);
        assert(deployment.l2OracleImpl.CHALLENGER() == deployment.buildCfg.l2OutputOracleChallenger);
    }

    function testOasysL2OutputOracle__PROPOSER() external view {
        assert(deployment.l2Oracle.PROPOSER() == deployment.buildCfg.l2OutputOracleProposer);
        assert(deployment.l2OracleImpl.PROPOSER() == deployment.buildCfg.l2OutputOracleProposer);
    }

    function test_OasysL2OutputOracle_FINALIZATION_PERIOD_SECONDS() external view {
        assert(deployment.l2Oracle.FINALIZATION_PERIOD_SECONDS() == deployment.buildCfg.finalizationPeriodSeconds);
        assert(deployment.l2OracleImpl.FINALIZATION_PERIOD_SECONDS() == deployment.buildCfg.finalizationPeriodSeconds);
    }

    function test_OasysL2OutputOracle_VERIFIER() external view {
        assert(address(deployment.l2Oracle.VERIFIER()) == address(l2OracleVerifier));
        assert(address(deployment.l2OracleImpl.VERIFIER()) == address(l2OracleVerifier));
    }

    function test_OasysL2OutputOracle_startingBlockNumber() external view {
        assert(deployment.l2Oracle.startingBlockNumber() == deployment.buildCfg.l2OutputOracleStartingBlockNumber);
        assert(deployment.l2OracleImpl.startingBlockNumber() == 0);
    }

    function test_OasysL2OutputOracle_startingTimestamp() external view {
        assert(deployment.l2Oracle.startingTimestamp() == deployment.buildCfg.l2OutputOracleStartingTimestamp);
        assert(deployment.l2OracleImpl.startingTimestamp() == 0);
    }

    /**
     * @dev Tests for `SystemConfig`
     */
    function test_SystemConfig_initialized() external {
        ResourceMetering.ResourceConfig memory cfg;
        vm.expectRevert("Initializable: contract is already initialized");
        deployment.systemConfig.initialize(address(0), 0, 0, bytes32(0), 0, address(0), cfg);
    }

    function test_SystemConfig_owner() external view {
        assert(deployment.systemConfig.owner() == deployment.buildCfg.finalSystemOwner);
        assert(deployment.systemConfigImpl.owner() == address(0xdEaD));
    }

    function test_SystemConfig_overhead() external view {
        assert(deployment.systemConfig.overhead() == 188);
        assert(deployment.systemConfigImpl.overhead() == 0);
    }

    function test_SystemConfig_scalar() external view {
        assert(deployment.systemConfig.scalar() == 684_000);
        assert(deployment.systemConfigImpl.scalar() == 0);
    }

    function test_SystemConfig_batcherHash() external view {
        bytes32 expect = bytes32(uint256(uint160(deployment.buildCfg.batchSenderAddress)));
        assert(deployment.systemConfig.batcherHash() == expect);
        assert(deployment.systemConfigImpl.batcherHash() == bytes32(0));
    }

    function test_SystemConfig_gasLimit() external view {
        assert(deployment.systemConfig.gasLimit() == deployment.buildCfg.l2GasLimit);
        assert(deployment.systemConfigImpl.gasLimit() == 20_000_000 + 1_000_000);
    }

    function test_SystemConfig_resourceConfig() external view {
        ResourceMetering.ResourceConfig memory expect = Constants.DEFAULT_RESOURCE_CONFIG();
        ResourceMetering.ResourceConfig memory actual = deployment.systemConfig.resourceConfig();

        assert(actual.maxResourceLimit == expect.maxResourceLimit);
        assert(actual.elasticityMultiplier == expect.elasticityMultiplier);
        assert(actual.baseFeeMaxChangeDenominator == expect.baseFeeMaxChangeDenominator);
        assert(actual.minimumBaseFee == expect.minimumBaseFee);
        assert(actual.systemTxMaxGas == expect.systemTxMaxGas);
        assert(actual.maximumBaseFee == expect.maximumBaseFee);
    }

    function test_SystemConfig_unsafeBlockSigner() external view {
        assert(deployment.systemConfig.unsafeBlockSigner() == deployment.buildCfg.p2pSequencerAddress);
        assert(deployment.systemConfigImpl.unsafeBlockSigner() == address(0));
    }

    /**
     * @dev Tests for `L1CrossDomainMessenger`
     */
    function test_L1CrossDomainMessenger_initialized() external {
        vm.expectRevert("Initializable: contract is already initialized");
        deployment.l1Messenger.initialize();
    }

    function test_L1CrossDomainMessenger_OTHER_MESSENGER() external view {
        assert(deployment.l1Messenger.OTHER_MESSENGER() == 0x4200000000000000000000000000000000000007);
        assert(deployment.l1MessengerImpl.OTHER_MESSENGER() == 0x4200000000000000000000000000000000000007);
    }

    function test_L1CrossDomainMessenger_PORTAL() external view {
        assert(address(deployment.l1Messenger.PORTAL()) == address(deployment.portal));
        assert(address(deployment.l1MessengerImpl.PORTAL()) == address(deployment.portal));
    }

    /**
     * @dev Tests for `L1StandardBridge`
     */
    function test_L1StandardBridge_MESSENGER() external view {
        assert(address(deployment.l1ERC20Bridge.MESSENGER()) == address(deployment.l1Messenger));
        assert(address(deployment.l1ERC20BridgeImpl.MESSENGER()) == address(deployment.l1Messenger));
    }

    function test_L1StandardBridge_OTHER_BRIDGE() external view {
        assert(address(deployment.l1ERC20Bridge.OTHER_BRIDGE()) == 0x4200000000000000000000000000000000000010);
        assert(address(deployment.l1ERC20BridgeImpl.OTHER_BRIDGE()) == 0x4200000000000000000000000000000000000010);
    }

    function test_L1StandardBridge_depositETH() external {
        vm.prank(alice);
        deployment.l1ERC20Bridge.depositETH{ value: 1 ether }(50000, hex"");
    }

    /**
     * @dev Tests for `L1ERC721Bridge`
     */
    function test_L1ERC721Bridge_MESSENGER() external view {
        assert(address(deployment.l1ERC721Bridge.MESSENGER()) == address(deployment.l1Messenger));
        assert(address(deployment.l1ERC721BridgeImpl.MESSENGER()) == address(deployment.l1Messenger));
    }

    function test_L1ERC721Bridge_OTHER_BRIDGE() external view {
        assert(address(deployment.l1ERC721Bridge.OTHER_BRIDGE()) == 0x6200000000000000000000000000000000000001);
        assert(address(deployment.l1ERC721BridgeImpl.OTHER_BRIDGE()) == 0x6200000000000000000000000000000000000001);
    }

    function test_L1ERC721Bridge_bridgeERC721() external {
        TestERC721 local = new TestERC721();
        TestERC721 remote = new TestERC721();
        uint256 tokenId = 1337;

        local.mint(alice, tokenId);

        vm.prank(alice);
        local.approve(address(deployment.l1ERC721Bridge), tokenId);

        vm.prank(alice);
        deployment.l1ERC721Bridge.bridgeERC721(address(local), address(remote), tokenId, 50000, hex"");
    }

    /**
     * @dev Tests for `ProtocolVersions`
     */
    function test_ProtocolVersions_initialized() external {
        vm.expectRevert("Initializable: contract is already initialized");
        deployment.protocolVersions.initialize(address(0), ProtocolVersion.wrap(0), ProtocolVersion.wrap(0));
    }

    function test_ProtocolVersions_owner() external view {
        assert(deployment.protocolVersions.owner() == deployment.buildCfg.finalSystemOwner);
        assert(deployment.protocolVersionsImpl.owner() == address(0xdEaD));
    }

    function test_ProtocolVersions_required() external view {
        assert(ProtocolVersion.unwrap(deployment.protocolVersions.required()) == 0);
        assert(ProtocolVersion.unwrap(deployment.protocolVersionsImpl.required()) == 0);
    }

    function test_ProtocolVersions_recommended() external view {
        assert(ProtocolVersion.unwrap(deployment.protocolVersions.recommended()) == 0);
        assert(ProtocolVersion.unwrap(deployment.protocolVersionsImpl.recommended()) == 0);
    }
}
