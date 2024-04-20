// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import { console2 as console } from "forge-std/console2.sol";
import { stdStorage, StdStorage } from "forge-std/Test.sol";

import { TestERC20 } from "test/mocks/TestERC20.sol";
import { TestERC721 } from "test/mocks/TestERC721.sol";
import { Constants } from "src/libraries/Constants.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ResolvedDelegateProxy } from "src/legacy/ResolvedDelegateProxy.sol";
import { L1ChugSplashProxy } from "src/legacy/L1ChugSplashProxy.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";

import { L1BuildAgentTestCommon } from "test/setup/oasys/SetupL1BuildAgent.sol";
import { MockLegacyL1BuildAgent } from "test/setup/oasys/MockLegacyL1BuildAgent.sol";
import { MockLegacyL1StandardBridge } from "test/setup/oasys/MockLegacyL1StandardBridge.sol";
import { MockLegacyL1ERC721Bridge } from "test/setup/oasys/MockLegacyL1ERC721Bridge.sol";

contract L1BuildAgentTest is L1BuildAgentTestCommon {
    using stdStorage for StdStorage;

    function setUp() public override {
        super.setUp();

        // Deploy OAS and deposit to the L1BuildDeposit
        vm.prank(depositor);
        l1Deposit.deposit{ value: 1 ether }(builder);

        vm.prank(builder);
        deployment = _runL1BuildAgent(
            5555,
            address(0),
            IL1BuildAgent.BuildConfig({
                finalSystemOwner: finalOwner,
                l2OutputOracleProposer: proposer,
                l2OutputOracleChallenger: challenger,
                batchSenderAddress: batcher,
                p2pSequencerAddress: p2pSequencer,
                messageRelayer: relayer,
                l2BlockTime: 5,
                l2GasLimit: 50_000_000,
                l2OutputOracleSubmissionInterval: 50,
                finalizationPeriodSeconds: 5 days,
                l2OutputOracleStartingBlockNumber: 500,
                l2OutputOracleStartingTimestamp: block.timestamp
            })
        );

        console.log("\nWallets");
        console.log("alice        : %s", alice);
        console.log("bob          : %s", bob);
        console.log("depositor    : %s", depositor);
        console.log("builder      : %s", builder);
        console.log("finalOwner   : %s", finalOwner);
        console.log("proposer     : %s", proposer);
        console.log("challenger   : %s", challenger);
        console.log("batcher      : %s", batcher);
        console.log("p2pSequencer : %s", p2pSequencer);
        console.log("relayer      : %s", relayer);

        console.log("\nDependency contracts");
        console.log("PermissionedContractFactory : %s", address(permissionedFactory));
        console.log("OasysL2OutputOracleVerifier : %s", address(l2OracleVerifier));

        console.log("\nL1 Build contracts");
        console.log("L1BuildAgent   : %s", address(l1Agent));
        console.log("L1BuildDeposit : %s", address(l1Deposit));

        console.log("\nProxies");
        console.log("OasysPortal            : %s", address(deployment.portal));
        console.log("OasysL2OutputOracle    : %s", address(deployment.l2Oracle));
        console.log("SystemConfig           : %s", address(deployment.systemConfig));
        console.log("L1CrossDomainMessenger : %s", address(deployment.l1Messenger));
        console.log("L1StandardBridge       : %s", address(deployment.l1ERC20Bridge));
        console.log("L1ERC721Bridge         : %s", address(deployment.l1ERC721Bridge));
        console.log("ProtocolVersions       : %s", address(deployment.protocolVersions));

        console.log("\nImplementations");
        console.log("OasysPortal            : %s", address(deployment.portalImpl));
        console.log("OasysL2OutputOracle    : %s", address(deployment.l2OracleImpl));
        console.log("SystemConfig           : %s", address(deployment.systemConfigImpl));
        console.log("L1CrossDomainMessenger : %s", address(deployment.l1MessengerImpl));
        console.log("L1StandardBridge       : %s", address(deployment.l1ERC20BridgeImpl));
        console.log("L1ERC721Bridge         : %s", address(deployment.l1ERC721BridgeImpl));
        console.log("ProtocolVersions       : %s", address(deployment.protocolVersionsImpl));
    }

    /**
     * @dev Tests for `ProxyAdmin`
     */
    function test_ProxyAdmin_proxyTypes() external view {
        assert(deployment.proxyAdmin.proxyType(address(deployment.portal)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l2Oracle)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.systemConfig)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1Messenger)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC20Bridge)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC721Bridge)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.protocolVersions)) == ProxyAdmin.ProxyType.ERC1967);
    }
}

contract L1BuildAgentUpgradeTest is L1BuildAgentTestCommon {
    TestERC20 l1ERC20;
    TestERC20 l2ERC20;
    TestERC721 l1ERC721;
    TestERC721 l2ERC721;

    uint256 depositedAmount;
    uint256 depositedTokenId;

    function setUp() public override {
        super.setUp();

        // Deploy legacy address manager, cross, standard bridge, erc721 bridge
        (address addressManager,, address l1StandardBridgeProxy, address l1ERC721BridgeProxy) = _deployLegacies();

        // Deploy ERC20 and ERC721 tokens
        _deployTokens();

        // Deposit ERC20 and ERC721 tokens to each bridges
        _depositTokensToBridge(l1StandardBridgeProxy, l1ERC721BridgeProxy);

        // Transfer ownership of the legacy contracts to the builder
        _transferOwnerships(addressManager, l1StandardBridgeProxy, l1ERC721BridgeProxy, address(l1Agent));

        // Mark the following chainId as built
        uint256 chainId = 5555;
        legacyAgent.setBuilder(builder, chainId);
        legacyAgent.setAddressManager(chainId, addressManager);
        legacyDeposit.setBuildBlock(builder, block.number);

        vm.prank(builder);
        deployment = _runL1BuildAgent(
            chainId,
            addressManager,
            IL1BuildAgent.BuildConfig({
                finalSystemOwner: finalOwner,
                l2OutputOracleProposer: proposer,
                l2OutputOracleChallenger: challenger,
                batchSenderAddress: batcher,
                p2pSequencerAddress: p2pSequencer,
                messageRelayer: relayer,
                l2BlockTime: 5,
                l2GasLimit: 50_000_000,
                l2OutputOracleSubmissionInterval: 50,
                finalizationPeriodSeconds: 5 days,
                l2OutputOracleStartingBlockNumber: 500,
                l2OutputOracleStartingTimestamp: block.timestamp
            })
        );

        // Clear the cross domain messenger address to prevent early deposits
        vm.prank(finalOwner);
        string memory contractName = "OVM_L1CrossDomainMessenger";
        deployment.proxyAdmin.setImplementationName(address(0), contractName);
    }

    function _deployLegacies() internal returns (address, address, address, address) {
        // Deploy address manager
        AddressManager addressManager = new AddressManager();
        // Deploy proxies
        ResolvedDelegateProxy l1CrossDomainMessengerProxy =
            new ResolvedDelegateProxy(addressManager, "OVM_L1CrossDomainMessenger");
        L1ChugSplashProxy l1StandardBridgeProxy = new L1ChugSplashProxy(address(this));
        L1ChugSplashProxy l1ERC721BridgeProxy = new L1ChugSplashProxy(address(this));
        // Deploy implementations
        L1CrossDomainMessenger l1CrossDomainMessenger = new L1CrossDomainMessenger(OptimismPortal(payable(0)));
        MockLegacyL1StandardBridge legacyStandardBridge = new MockLegacyL1StandardBridge();
        MockLegacyL1ERC721Bridge legacyERC721Bridge = new MockLegacyL1ERC721Bridge();
        // Set addresses to address manager
        addressManager.setAddress("Proxy__OVM_L1CrossDomainMessenger", address(l1CrossDomainMessengerProxy));
        addressManager.setAddress("Proxy__OVM_L1StandardBridge", address(l1StandardBridgeProxy));
        addressManager.setAddress("Proxy__OVM_L1ERC721Bridge", address(l1ERC721BridgeProxy));
        addressManager.setAddress("OVM_L1CrossDomainMessenger", address(l1CrossDomainMessenger));
        addressManager.setAddress("OVM_CanonicalTransactionChain", address(l1CrossDomainMessenger)); // dummy, expected
            // to be set zero value after build
        // Transfer ownership of the address manager to the builder
        addressManager.transferOwnership(builder);
        // Set implementations to proxies
        l1StandardBridgeProxy.setStorage(
            Constants.PROXY_IMPLEMENTATION_ADDRESS, bytes32(uint256(uint160(address(legacyStandardBridge))))
        );
        l1StandardBridgeProxy.setOwner(builder);
        l1ERC721BridgeProxy.setStorage(
            Constants.PROXY_IMPLEMENTATION_ADDRESS, bytes32(uint256(uint160(address(legacyERC721Bridge))))
        );
        l1ERC721BridgeProxy.setOwner(builder);
        return (
            address(addressManager),
            address(l1CrossDomainMessengerProxy),
            address(l1StandardBridgeProxy),
            address(l1ERC721BridgeProxy)
        );
    }

    function _deployTokens() internal {
        l1ERC20 = new TestERC20();
        l2ERC20 = new TestERC20();
        l1ERC721 = new TestERC721();
        l2ERC721 = new TestERC721();
    }

    function _depositTokensToBridge(address l1StandardBridgeProxy, address l1ERC721BridgeProxy) internal {
        // Deposit OAS
        depositedAmount = 1 ether;
        MockLegacyL1StandardBridge(l1StandardBridgeProxy).depositETH{ value: depositedAmount }(50000, hex"");
        // Deposit ERC20
        deal(address(l1ERC20), address(alice), depositedAmount);
        vm.prank(alice);
        l1ERC20.approve(l1StandardBridgeProxy, depositedAmount);
        vm.prank(alice);
        MockLegacyL1StandardBridge(l1StandardBridgeProxy).depositERC20(
            address(l1ERC20), address(l2ERC20), depositedAmount, 50000, hex""
        );
        // Deposit ERC721
        depositedTokenId = 1243;
        l1ERC721.mint(alice, depositedTokenId);
        vm.prank(alice);
        l1ERC721.approve(l1ERC721BridgeProxy, depositedTokenId);
        vm.prank(alice);
        MockLegacyL1ERC721Bridge(l1ERC721BridgeProxy).depositERC721(
            address(l1ERC721), address(l2ERC721), depositedTokenId, 50000, hex""
        );
    }

    function _transferOwnerships(address manager, address chugProxy1, address chugProxy2, address newOwner) internal {
        vm.prank(builder);
        AddressManager(manager).transferOwnership(newOwner);
        vm.prank(builder);
        L1ChugSplashProxy(payable(chugProxy1)).setOwner(newOwner);
        vm.prank(builder);
        L1ChugSplashProxy(payable(chugProxy2)).setOwner(newOwner);
    }

    /**
     * @dev Tests for `ProxyAdmin`
     */
    function test_ProxyAdmin_addressManager() external view {
        assert(address(deployment.proxyAdmin.addressManager()) == address(deployment.addressManager));
    }

    function test_ProxyAdmin_proxyTypes_succeeds() external view {
        assert(deployment.proxyAdmin.proxyType(address(deployment.portal)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l2Oracle)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.systemConfig)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1Messenger)) == ProxyAdmin.ProxyType.RESOLVED);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC20Bridge)) == ProxyAdmin.ProxyType.CHUGSPLASH);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC721Bridge)) == ProxyAdmin.ProxyType.CHUGSPLASH);
        assert(deployment.proxyAdmin.proxyType(address(deployment.protocolVersions)) == ProxyAdmin.ProxyType.ERC1967);
    }

    function test_ProxyAdmin_implementationNames() external view {
        assert(
            // keccak256(abi.encode(deployment.proxyAdmin.implementationName(address(deployment.l1Messenger))))
            keccak256(abi.encode(deployment.proxyAdmin.implementationName(address(0))))
                == keccak256(abi.encode("OVM_L1CrossDomainMessenger"))
        );
    }

    function test_ProxyAdmin_addressManager_succeeds() external {
        assertEq(address(deployment.proxyAdmin.addressManager()), address(deployment.addressManager));
    }

    function test_ProxyAdmin_AddressManager_owner_succeeds() external {
        assertEq(deployment.addressManager.owner(), address(deployment.proxyAdmin));
    }

    /**
     * @dev Tests for `AddressManager`
     */
    function test_AddressManager_owner() external view {
        assert(deployment.addressManager.owner() == address(deployment.proxyAdmin));
    }

    function test_AddressManager_getAddress_OVM_L1CrossDomainMessenger() external view {
        assert(
            deployment.addressManager.getAddress("OVM_L1CrossDomainMessenger") == address(deployment.l1MessengerImpl)
        );
    }

    function test_AddressManager_getAddress_DTL_SHUTOFF_BLOCK_succeeds() external {
        assertEq(deployment.addressManager.getAddress("DTL_SHUTOFF_BLOCK"), address(uint160(block.number)));
    }

    function test_AddressManager_getAddress_OVM_CanonicalTransactionChain_succeeds() external {
        // legacy addresses are expected to be set zero value
        assertEq(deployment.addressManager.getAddress("OVM_CanonicalTransactionChain"), address(0));
    }

    /**
     * @dev Tests OAS/ERC20/ERC721 balance migration
     */
    function test_OAS_migration_succeeds() external {
        // OAS expected to be transferred to OasysPortal
        assertEq(address(deployment.portal).balance, depositedAmount);
    }

    function test_ERC20_migration_succeeds() external {
        assertEq(l1ERC20.balanceOf(address(deployment.l1ERC20Bridge)), depositedAmount);
        assertEq(
            L1StandardBridge(deployment.l1ERC20Bridge).deposits(address(l1ERC20), address(l2ERC20)), depositedAmount
        );
    }

    function test_ERC721_migration_succeeds() external {
        assertEq(l1ERC721.ownerOf(depositedTokenId), address(deployment.l1ERC721Bridge));
        assertEq(
            L1ERC721Bridge(deployment.l1ERC721Bridge).deposits(address(l1ERC721), address(l2ERC721), depositedTokenId),
            true
        );
    }
}
