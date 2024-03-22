// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { console2 as console } from "forge-std/console2.sol";
import { stdStorage, StdStorage } from "forge-std/Test.sol";

import { Constants } from "src/libraries/Constants.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { ProtocolVersion } from "src/L1/ProtocolVersions.sol";

import { SetupL1BuildAgent } from "test/setup/oasys/SetupL1BuildAgent.sol";

contract TestERC721 is ERC721 {
    constructor() ERC721("Test", "TST") { }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract L1BuildAgentTest is SetupL1BuildAgent {
    using stdStorage for StdStorage;

    function test_batchInbox() external view {
        assert(deployment.batchInbox == 0xfF00000000000000000000000000000015B3FF00);
    }

    /**
     * @dev Tests for `ProxyAdmin`
     */
    function test_ProxyAdmin_owner() external view {
        assert(deployment.proxyAdmin.owner() == deployment.buildCfg.finalSystemOwner);
    }

    function test_ProxyAdmin_addressManager() external view {
        assert(address(deployment.proxyAdmin.addressManager()) == address(deployment.addressManager));
    }

    function test_ProxyAdmin_proxyTypes() external view {
        assert(deployment.proxyAdmin.proxyType(address(deployment.portal)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l2Oracle)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.systemConfig)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1Messenger)) == ProxyAdmin.ProxyType.RESOLVED);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC20Bridge)) == ProxyAdmin.ProxyType.CHUGSPLASH);
        assert(deployment.proxyAdmin.proxyType(address(deployment.l1ERC721Bridge)) == ProxyAdmin.ProxyType.ERC1967);
        assert(deployment.proxyAdmin.proxyType(address(deployment.protocolVersions)) == ProxyAdmin.ProxyType.ERC1967);
    }

    function test_ProxyAdmin_implementationNames() external view {
        assert(
            keccak256(abi.encode(deployment.proxyAdmin.implementationName(address(deployment.l1Messenger))))
                == keccak256(abi.encode("OVM_L1CrossDomainMessenger"))
        );
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
        assert(deployment.portal.messageRelayer() == address(0));
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
