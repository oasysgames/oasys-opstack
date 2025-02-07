// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Openzeppelin Libraries
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// Forge testing utilities
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";

// Libraries
import { Types } from "src/libraries/Types.sol";

// Core Optimism contracts
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";

// Universal contracts and interfaces
import { ISemver } from "src/universal/ISemver.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";

// Builder interfaces
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";

// Target upgrade contracts
import { IUpgradeManager } from "src/oasys/L1/upgrade/IUpgradeManager.sol";
import { IUpgradeImplementer } from "src/oasys/L1/upgrade/IUpgradeImplementer.sol";
import { UpgradeManager } from "src/oasys/L1/upgrade/UpgradeManager.sol";
import { BedrockToGranite } from "src/oasys/L1/upgrade/BedrockToGranite.sol";

// Mock contracts for testing
import { MockLegacyL1BuildAgent } from "test/setup/oasys/MockLegacyL1BuildAgent.sol";
import { MockLegacyL1BuildDeposit } from "test/setup/oasys/MockLegacyL1BuildDeposit.sol";

// Test setup
import { SetupL1BuildAgent } from "./SetupBedrock.sol";

interface L1BuildAgentImpl is ISemver {
    function L2OO_VERIFIER() external view returns (address);
}

interface BedrockOasysPortal is ISemver {
    function L2_ORACLE() external view returns (address);
    function SYSTEM_CONFIG() external view returns (address);
    function GUARDIAN() external view returns (address);
    function finalizedWithdrawals(bytes32) external view returns (bool);
    function provenWithdrawals(bytes32)
        external
        view
        returns (bytes32 outputRoot, uint128 timestamp, uint128 l2OutputIndex);
    function messageRelayer() external view returns (address);
}

interface BedrockOasysL2OutputOracle is ISemver {
    function SUBMISSION_INTERVAL() external view returns (uint256);
    function L2_BLOCK_TIME() external view returns (uint256);
    function CHALLENGER() external view returns (address);
    function PROPOSER() external view returns (address);
    function FINALIZATION_PERIOD_SECONDS() external view returns (uint256);
    function VERIFIER() external view returns (address);
    function startingBlockNumber() external view returns (uint256);
    function startingTimestamp() external view returns (uint256);
    function getL2Output(uint256) external view returns (Types.OutputProposal memory);
    function nextVerifyIndex() external view returns (uint256);
}

interface BedrockSystemConfig is ISemver {
    function owner() external view returns (address);
    function overhead() external view returns (uint256);
    function scalar() external view returns (uint256);
    function batcherHash() external view returns (bytes32);
    function gasLimit() external view returns (uint64);
    function resourceConfig() external view returns (ResourceMetering.ResourceConfig memory);
}

interface BedrockL1CrossDomainMessenger is ISemver {
    function OTHER_MESSENGER() external view returns (address);
    function PORTAL() external view returns (address);
    function successfulMessages(bytes32) external view returns (bool);
    function failedMessages(bytes32) external view returns (bool);
}

interface BedrockL1StandardBridge is ISemver {
    function MESSENGER() external view returns (address);
    function OTHER_BRIDGE() external view returns (address);
    function deposits(address, address) external view returns (uint256);
}

interface BedrockOasysL1ERC721Bridge is ISemver {
    function MESSENGER() external view returns (address);
    function OTHER_BRIDGE() external view returns (address);
    function deposits(address, address, uint256) external view returns (bool);
}

contract FakeUpgradeImplementer is IERC165, IUpgradeImplementer {
    string public constant upgradeName = "Fake";
    uint256 public constant totalSteps = 1;

    uint256 public immutable implementerIndex;

    constructor(uint256 _implementerIndex) {
        implementerIndex = _implementerIndex;
    }

    function supportsInterface(bytes4 _interfaceId) public pure override(IERC165) returns (bool) {
        return _interfaceId == type(IUpgradeImplementer).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }

    function executeUpgradeStep(uint256 _chainId, uint8 _step) external returns (bool _completed) {
        return true;
    }
}

contract L1UpgradeManager_Test is Test, IERC165 {
    event ImplementerAdded(address indexed implementer, uint256 indexed implementerIndex, string indexed upgradeName);
    event ProxyAdminOwnerRegistered(uint256 indexed chainId, address indexed owner);
    event ProxyAdminOwnerReleased(uint256 indexed chainId, address indexed owner);
    event ProxyUpgraded(uint256 indexed chainId, address indexed proxy, address implementation);
    event UpgradeStepAdvanced(uint256 indexed chainId, string indexed upgradeName, uint256 step, uint256 totalSteps);
    event UpgradeCompleted(uint256 indexed chainId, string indexed upgradeName);
    event SuperchainConfigProxyDeployed(uint256 indexed chainId, address proxy);

    enum Upgrade {
        BEDROCK,
        GRANITE
    }

    address public deployer;
    address public depositor;
    address public verseBuilder;
    address public finalSystemOwner;
    address public l2ooProposer;
    address public l2ooChallenger;
    address public batchSender;
    address public p2pSequencer;
    address public messageRelayer;
    address public managerOwner;

    uint256 public chainId = 4200;
    IL1BuildAgent public buildAgent;
    IL1BuildDeposit public buildDeposit;
    UpgradeManager public upgradeManager;
    IL1BuildAgent.BuildConfig public buildCfg;
    IL1BuildAgent.BuiltAddressList public builts;
    ProxyAdmin proxyAdmin;

    function setUp() public virtual {
        // Setup wallets
        deployer = makeAddr("deployer");
        depositor = makeAddr("depositor");
        verseBuilder = makeAddr("verseBuilder");
        finalSystemOwner = makeAddr("finalSystemOwner");
        l2ooProposer = makeAddr("l2ooProposer");
        l2ooChallenger = makeAddr("l2ooChallenger");
        batchSender = makeAddr("batchSender");
        p2pSequencer = makeAddr("p2pSequencer");
        messageRelayer = makeAddr("messageRelayer");
        console.log("deployer: %s", deployer);
        console.log("depositor: %s", depositor);
        console.log("verseBuilder: %s", verseBuilder);
        console.log("finalSystemOwner: %s", finalSystemOwner);
        console.log("l2ooProposer: %s", l2ooProposer);
        console.log("l2ooChallenger: %s", l2ooChallenger);
        console.log("batchSender: %s", batchSender);
        console.log("p2pSequencer: %s", p2pSequencer);
        console.log("messageRelayer: %s", messageRelayer);
        console.log();

        // Deploy L1BuildAgent and L1BuildDeposit
        vm.prank(deployer);
        (buildAgent, buildDeposit) = (new SetupL1BuildAgent()).deploy();
        console.log("L1BuildAgent: %s", address(buildAgent));
        console.log("L1BuildDeposit: %s", address(buildDeposit));
        console.log();

        // Deploy UpgradeManager
        vm.prank(deployer);
        upgradeManager = new UpgradeManager({ _owner: deployer, _buildAgent: address(buildAgent) });
        console.log("UpgradeManager: %s", address(upgradeManager));
        console.log();

        // Make build config
        buildCfg = IL1BuildAgent.BuildConfig({
            finalSystemOwner: finalSystemOwner,
            l2OutputOracleProposer: l2ooProposer,
            l2OutputOracleChallenger: l2ooChallenger,
            batchSenderAddress: batchSender,
            p2pSequencerAddress: p2pSequencer,
            messageRelayer: messageRelayer,
            l2BlockTime: 2,
            l2GasLimit: 30_000_000,
            l2OutputOracleSubmissionInterval: 3600,
            finalizationPeriodSeconds: 7 days,
            l2OutputOracleStartingBlockNumber: 12345,
            l2OutputOracleStartingTimestamp: block.timestamp
        });

        // Deposit to L1BuildDeposit
        vm.deal(depositor, 1 ether);
        vm.prank(depositor);
        buildDeposit.deposit{ value: 1 ether }({ _builder: verseBuilder });
        uint256 depositTotal = buildDeposit.getDepositTotal({ _builder: verseBuilder });
        console.log("Deposited %s to L1BuildDeposit", vm.toString(depositTotal));
        console.log();

        // Deploy Bedrock contracts
        vm.prank(verseBuilder);
        (builts,) = buildAgent.build({ chainId: chainId, cfg: buildCfg });
        proxyAdmin = ProxyAdmin(builts.proxyAdmin);
        console.log("proxyAdmin: %s", builts.proxyAdmin);
        console.log("systemConfig: %s", builts.systemConfig);
        console.log("l1StandardBridge: %s", builts.l1StandardBridge);
        console.log("l1ERC721Bridge: %s", builts.l1ERC721Bridge);
        console.log("l1CrossDomainMessenger: %s", builts.l1CrossDomainMessenger);
        console.log("oasysL2OutputOracle: %s", builts.oasysL2OutputOracle);
        console.log("oasysPortal: %s", builts.oasysPortal);
        console.log("batchInbox: %s", builts.batchInbox);
        console.log();

        // Check deployed contracts
        _assert_SuperchainConfig(Upgrade.BEDROCK);
        _assert_OasysPortal(Upgrade.BEDROCK);
        _assert_OasysL2OutputOracle(Upgrade.BEDROCK);
        _assert_SystemConfig(Upgrade.BEDROCK);
        _assert_L1CrossDomainMessenger(Upgrade.BEDROCK);
        _assert_L1StandardBridge(Upgrade.BEDROCK);
        _assert_L1ERC721Bridge(Upgrade.BEDROCK);
    }

    function test_addNextImplementer() public {
        FakeUpgradeImplementer _implementer = new FakeUpgradeImplementer(0);

        vm.expectEmit(address(upgradeManager));
        emit ImplementerAdded(address(_implementer), 0, "Fake");

        vm.prank(deployer);
        upgradeManager.addNextImplementer(_implementer);
    }

    function test_addNextImplementer_errors() public {
        // Check `Ownable: caller is not the owner` error
        FakeUpgradeImplementer _implementer = new FakeUpgradeImplementer(0);
        vm.expectRevert("Ownable: caller is not the owner");
        upgradeManager.addNextImplementer(_implementer);

        // Check `invalid implementer index` error
        _implementer = new FakeUpgradeImplementer(2);
        vm.prank(deployer);
        vm.expectRevert("UpgradeManager: invalid implementer index");
        upgradeManager.addNextImplementer(_implementer);
    }

    function test_registerProxyAdminOwnerBeforeTransfer() public {
        vm.expectEmit(address(upgradeManager));
        emit ProxyAdminOwnerRegistered(chainId, finalSystemOwner);

        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);
        assert(upgradeManager.proxyAdminOwners(chainId) == finalSystemOwner);
    }

    function test_registerProxyAdminOwnerBeforeTransfer_errors() public {
        // Check `invalid chain-id` error
        vm.expectRevert("UpgradeManager: invalid chain-id");
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId + 1);

        // Check `caller is not the ProxyAdmin owner` error
        vm.prank(deployer);
        vm.expectRevert("UpgradeManager: caller is not the ProxyAdmin owner");
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // Run `registerProxyAdminOwnerBeforeTransfer`
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // Check `already prepared` error
        vm.prank(finalSystemOwner);
        vm.expectRevert("UpgradeManager: already prepared");
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);
    }

    function test_registerProxyAdminOwnerBeforeTransfer_error_after_transferred() public {
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        vm.prank(finalSystemOwner);
        vm.expectRevert(
            bytes(
                string.concat(
                    "UpgradeManager: ProxyAdmin ownership has been transferred before preparation.",
                    " Please contact the UpgradeManager owner to restore ownership."
                )
            )
        );
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);
    }

    function test_releaseProxyAdminOwnership() public {
        // Run `registerProxyAdminOwnerBeforeTransfer`
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // Transfer ProxyAdmin owner to UpgradeManager
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        // Run `releaseProxyAdminOwnership`
        vm.expectEmit(address(upgradeManager));
        emit ProxyAdminOwnerReleased(chainId, finalSystemOwner);

        vm.prank(finalSystemOwner);
        upgradeManager.releaseProxyAdminOwnership(chainId);

        assert(proxyAdmin.owner() == finalSystemOwner);
        assert(upgradeManager.proxyAdminOwners(chainId) == address(0));
    }

    function test_releaseProxyAdminOwnership_errors() public {
        // Check `invalid chain-id` error
        vm.expectRevert("UpgradeManager: invalid chain-id");
        upgradeManager.releaseProxyAdminOwnership(chainId + 1);

        // Check `not prepared` error
        vm.expectRevert("UpgradeManager: not prepared");
        upgradeManager.releaseProxyAdminOwnership(chainId);

        // Run `registerProxyAdminOwnerBeforeTransfer`
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // Check `caller is not the ProxyAdmin owner` error
        vm.prank(verseBuilder);
        vm.expectRevert("UpgradeManager: caller is not the ProxyAdmin owner");
        upgradeManager.releaseProxyAdminOwnership(chainId);

        // Check `has no ownership` error
        vm.prank(finalSystemOwner);
        vm.expectRevert("UpgradeManager: has no ownership");
        upgradeManager.releaseProxyAdminOwnership(chainId);
    }

    function test_transferProxyAdminOwner() public {
        // Transfer ProxyAdmin owner to UpgradeManager
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        // Run `transferProxyAdminOwner`
        vm.expectEmit(address(upgradeManager));
        emit ProxyAdminOwnerRegistered(chainId, address(1));
        vm.expectEmit(address(upgradeManager));
        emit ProxyAdminOwnerReleased(chainId, address(1));

        vm.prank(deployer);
        upgradeManager.transferProxyAdminOwner(chainId, address(1));

        assert(proxyAdmin.owner() == address(1));
        assert(upgradeManager.proxyAdminOwners(chainId) == address(0));
    }

    function test_transferProxyAdminOwner_errors() public {
        // Check `Ownable: caller is not the owner` error
        vm.expectRevert("Ownable: caller is not the owner");
        upgradeManager.transferProxyAdminOwner(chainId, address(1));

        // Check `invalid chain-id` error
        vm.prank(deployer);
        vm.expectRevert("UpgradeManager: invalid chain-id");
        upgradeManager.transferProxyAdminOwner(chainId + 1, address(1));

        // Transfer ProxyAdmin owner to UpgradeManager
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        // Check `owner is zero address` error
        vm.prank(deployer);
        vm.expectRevert("UpgradeManager: owner is zero address");
        upgradeManager.transferProxyAdminOwner(chainId, address(0));
    }

    address superchainConfigProxy;

    function test_upgradeContracts_BedrockToGranite() public {
        // Add BedrockToGranite implementer to UpgradeManager
        BedrockToGranite bedrockToGranite = _add_BedrockToGranite_Implementer();

        // UPGRADE STEP 1: Run `registerProxyAdminOwnerBeforeTransfer`
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // UPGRADE STEP 2: Transfer ProxyAdmin owner to UpgradeManager
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        // UPGRADE STEP 3: Run `upgradeContracts`
        vm.expectEmit(address(bedrockToGranite));
        emit SuperchainConfigProxyDeployed(chainId, 0x45C92C2Cd0dF7B2d705EF12CfF77Cb0Bc557Ed22);
        vm.expectEmit(address(upgradeManager));
        emit ProxyUpgraded(chainId, builts.systemConfig, bedrockToGranite.SYSTEM_CONFIG());
        vm.expectEmit(address(upgradeManager));
        emit UpgradeStepAdvanced(chainId, "Granite", 1, 1);
        vm.expectEmit(address(upgradeManager));
        emit UpgradeCompleted(chainId, "Granite");

        vm.prank(finalSystemOwner);
        upgradeManager.upgradeContracts(chainId);
        (superchainConfigProxy,,,,,,) = bedrockToGranite.proxies(chainId);

        // Check if ProxyAdmin owner is released
        assert(proxyAdmin.owner() == finalSystemOwner);

        // Check upgraded contracts
        _assert_SuperchainConfig(Upgrade.GRANITE);
        _assert_OasysPortal(Upgrade.GRANITE);
        _assert_OasysL2OutputOracle(Upgrade.GRANITE);
        _assert_SystemConfig(Upgrade.GRANITE);
        _assert_L1CrossDomainMessenger(Upgrade.GRANITE);
        _assert_L1StandardBridge(Upgrade.GRANITE);
        _assert_L1ERC721Bridge(Upgrade.GRANITE);
    }

    function test_upgradeContracts_BedrockToGranite_errors() public {
        // Check `invalid chain-id` error
        vm.expectRevert("UpgradeManager: invalid chain-id");
        upgradeManager.upgradeContracts(chainId + 1);

        // Check `not prepared` error
        vm.expectRevert("UpgradeManager: not prepared");
        upgradeManager.upgradeContracts(chainId);

        // Run `registerProxyAdminOwnerBeforeTransfer`
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);

        // Check `caller is not the ProxyAdmin owner` error
        vm.prank(verseBuilder);
        vm.expectRevert("UpgradeManager: caller is not the ProxyAdmin owner");
        upgradeManager.upgradeContracts(chainId);

        // Check `please transfer ProxyAdmin ownership to UpgradeManager` error
        vm.prank(finalSystemOwner);
        vm.expectRevert("UpgradeManager: please transfer ProxyAdmin ownership to UpgradeManager");
        upgradeManager.upgradeContracts(chainId);

        // Transfer ProxyAdmin owner to UpgradeManager
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));

        // Check `no implementers` error
        vm.prank(finalSystemOwner);
        vm.expectRevert("UpgradeManager: no implementers");
        upgradeManager.upgradeContracts(chainId);

        // Deploy BedrockToGranite implementer
        BedrockToGranite bedrockToGranite = _add_BedrockToGranite_Implementer();

        // Check `BedrockToGranite: caller is not L1UpgradeManager` error
        vm.prank(msg.sender);
        vm.expectRevert("BedrockToGranite: caller is not L1UpgradeManager");
        bedrockToGranite.executeUpgradeStep(chainId, 1);

        // Check `BedrockToGranite: step must be 1` error
        vm.prank(address(this));
        vm.expectRevert("BedrockToGranite: step must be 1");
        bedrockToGranite.executeUpgradeStep(chainId, 2);

        // Do upgrades
        vm.prank(finalSystemOwner);
        upgradeManager.upgradeContracts(chainId);

        // Check `your network is up-to-date` error
        vm.prank(finalSystemOwner);
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(chainId);
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(upgradeManager));
        vm.prank(finalSystemOwner);
        vm.expectRevert("UpgradeManager: your network is up-to-date");
        upgradeManager.upgradeContracts(chainId);
    }

    function _assert_SuperchainConfig(Upgrade _upgrade) internal view {
        SuperchainConfig granite = SuperchainConfig(superchainConfigProxy);

        if (_upgrade == Upgrade.BEDROCK) {
            // no deploy
        } else {
            vm.assertEq(granite.version(), "1.1.0");
            assert(granite.guardian() == finalSystemOwner);
            assert(granite.paused() == false);
        }
    }

    function _assert_OasysPortal(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockOasysPortal bedrock = BedrockOasysPortal(builts.oasysPortal);
            vm.assertEq(bedrock.version(), "1.11.0");
            assert(bedrock.L2_ORACLE() == builts.oasysL2OutputOracle);
            assert(bedrock.SYSTEM_CONFIG() == builts.systemConfig);
            assert(bedrock.GUARDIAN() == finalSystemOwner);
            assert(bedrock.messageRelayer() == messageRelayer);
        } else {
            OasysPortal granite = OasysPortal(payable(builts.oasysPortal));
            vm.assertEq(granite.version(), "2.8.0");
            assert(address(granite.superchainConfig()) == superchainConfigProxy);
            assert(address(granite.l2Oracle()) == builts.oasysL2OutputOracle);
            assert(address(granite.systemConfig()) == builts.systemConfig);
            assert(granite.guardian() == finalSystemOwner);
            assert(granite.messageRelayer() == messageRelayer);
        }

        // Check if storage gaps are reserved in multiples of 50
        {
            bytes32 slot = bytes32(uint256(50 + 12 + 38)); // ResourceMetering(50) + OptimismPortal(12+38) = 100
            bytes32 value = vm.load(builts.oasysPortal, slot);
            assert(value == bytes32(uint256(uint160(messageRelayer))));
        }

        // finalizedWithdrawals
        {
            bytes32 mapKey = bytes32("finalizedWithdrawals");
            bytes memory _calldata = abi.encodeWithSelector(BedrockOasysPortal.finalizedWithdrawals.selector, mapKey);

            bytes32 rootSlot = bytes32(uint256(50 + 1)); // ResourceMetering(50) + OptimismPortal(1)
            bytes32 valueSlot = keccak256(abi.encodePacked(mapKey, rootSlot));

            // set to false
            vm.store(builts.oasysPortal, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.oasysPortal.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == false);

            // set to true
            vm.store(builts.oasysPortal, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.oasysPortal.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == true);
        }

        // provenWithdrawals
        {
            bytes32 mapKey = bytes32("provenWithdrawals");
            bytes memory _calldata = abi.encodeWithSelector(BedrockOasysPortal.provenWithdrawals.selector, mapKey);

            bytes32 rootSlot = bytes32(uint256(50 + 2)); // ResourceMetering(50) + OptimismPortal(2)
            bytes32 valueSlot = keccak256(abi.encodePacked(mapKey, rootSlot));

            // set to empty value
            vm.store(builts.oasysPortal, bytes32(uint256(valueSlot) + 0), bytes32(uint256(0))); // outputRoot
            vm.store(
                builts.oasysPortal,
                bytes32(uint256(valueSlot) + 1),
                bytes32(
                    abi.encodePacked(
                        uint128(0), // l2OutputIndex
                        uint128(0) // timestamp
                    )
                )
            );
            (bool success, bytes memory returndata) = builts.oasysPortal.call(_calldata);
            (bytes32 outputRoot, uint128 timestamp, uint128 l2OutputIndex) =
                abi.decode(returndata, (bytes32, uint128, uint128));
            assert(success);
            assert(outputRoot == bytes32(0));
            assert(timestamp == 0);
            assert(l2OutputIndex == 0);

            // set to outputRoot=1, timestamp=2, l2OutputIndex=3
            vm.store(builts.oasysPortal, bytes32(uint256(valueSlot) + 0), bytes32(uint256(1))); // outputRoot
            vm.store(
                builts.oasysPortal,
                bytes32(uint256(valueSlot) + 1),
                bytes32(
                    abi.encodePacked(
                        uint128(3), // l2OutputIndex
                        uint128(2) // timestamp
                    )
                )
            );
            (success, returndata) = builts.oasysPortal.call(_calldata);
            (outputRoot, timestamp, l2OutputIndex) = abi.decode(returndata, (bytes32, uint128, uint128));
            assert(success);
            assert(outputRoot == bytes32(uint256(1)));
            assert(timestamp == 2);
            assert(l2OutputIndex == 3);
        }
    }

    function _assert_OasysL2OutputOracle(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockOasysL2OutputOracle bedrock = BedrockOasysL2OutputOracle(builts.oasysL2OutputOracle);
            vm.assertEq(bedrock.version(), "1.7.0");
            assert(bedrock.SUBMISSION_INTERVAL() == buildCfg.l2OutputOracleSubmissionInterval);
            assert(bedrock.L2_BLOCK_TIME() == buildCfg.l2BlockTime);
            assert(bedrock.CHALLENGER() == l2ooChallenger);
            assert(bedrock.PROPOSER() == l2ooProposer);
            assert(bedrock.FINALIZATION_PERIOD_SECONDS() == buildCfg.finalizationPeriodSeconds);
            assert(address(bedrock.VERIFIER()) == L1BuildAgentImpl(address(buildAgent)).L2OO_VERIFIER());
            assert(bedrock.startingBlockNumber() == buildCfg.l2OutputOracleStartingBlockNumber);
            assert(bedrock.startingTimestamp() == buildCfg.l2OutputOracleStartingTimestamp);
        } else {
            OasysL2OutputOracle granite = OasysL2OutputOracle(builts.oasysL2OutputOracle);
            vm.assertEq(granite.version(), "1.8.0");
            assert(granite.SUBMISSION_INTERVAL() == buildCfg.l2OutputOracleSubmissionInterval);
            assert(granite.L2_BLOCK_TIME() == buildCfg.l2BlockTime);
            assert(granite.CHALLENGER() == l2ooChallenger);
            assert(granite.PROPOSER() == l2ooProposer);
            assert(granite.FINALIZATION_PERIOD_SECONDS() == buildCfg.finalizationPeriodSeconds);
            assert(address(granite.VERIFIER()) == L1BuildAgentImpl(address(buildAgent)).L2OO_VERIFIER());
            assert(granite.startingBlockNumber() == buildCfg.l2OutputOracleStartingBlockNumber);
            assert(granite.startingTimestamp() == buildCfg.l2OutputOracleStartingTimestamp);
        }

        // l2Outputs
        {
            uint256 arrIndex = 0;
            bytes memory _calldata = abi.encodeWithSelector(BedrockOasysL2OutputOracle.getL2Output.selector, arrIndex);

            bytes32 rootSlot = bytes32(uint256(1 + 2)); // Initializable(1) + L2OutputOracle(2)
            bytes32 valueSlot = keccak256(abi.encodePacked(rootSlot));

            // set to empty value
            vm.store(builts.oasysL2OutputOracle, rootSlot, bytes32(uint256(0))); // array length
            vm.store(builts.oasysL2OutputOracle, bytes32(uint256(valueSlot) + 0), bytes32(uint256(0))); // outputRoot
            vm.store(
                builts.oasysL2OutputOracle,
                bytes32(uint256(valueSlot) + 1),
                bytes32(
                    abi.encodePacked(
                        uint128(0), // l2BlockNumber
                        uint128(0) // timestamp
                    )
                )
            );
            vm.expectRevert();
            (bool success, bytes memory returndata) = builts.oasysL2OutputOracle.call(_calldata);

            // set to outputRoot=1, timestamp=2, l2BlockNumber=3
            vm.store(builts.oasysL2OutputOracle, rootSlot, bytes32(uint256(1))); // array length
            vm.store(builts.oasysL2OutputOracle, bytes32(uint256(valueSlot) + 0), bytes32(uint256(1))); // outputRoot
            vm.store(
                builts.oasysL2OutputOracle,
                bytes32(uint256(valueSlot) + 1),
                bytes32(
                    abi.encodePacked(
                        uint128(3), // l2BlockNumber
                        uint128(2) // timestamp
                    )
                )
            );
            (success, returndata) = builts.oasysL2OutputOracle.call(_calldata);
            Types.OutputProposal memory proposal = abi.decode(returndata, (Types.OutputProposal));
            assert(success);
            assert(proposal.outputRoot == bytes32(uint256(1)));
            assert(proposal.timestamp == 2);
            assert(proposal.l2BlockNumber == 3);
        }

        // nextVerifyIndex
        {
            bytes memory _calldata = abi.encodeWithSelector(BedrockOasysL2OutputOracle.nextVerifyIndex.selector);

            // Also verify that storage gaps are reserved in multiples of 50
            bytes32 valueSlot = bytes32(uint256(1 + 3 + 46)); // Initializable(1) + L2OutputOracle(3+46) = 50

            // set to 0
            vm.store(builts.oasysL2OutputOracle, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.oasysL2OutputOracle.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (uint256)) == 0);

            // set to 1
            vm.store(builts.oasysL2OutputOracle, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.oasysL2OutputOracle.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (uint256)) == 1);
        }
    }

    function _assert_SystemConfig(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockSystemConfig bedrock = BedrockSystemConfig(builts.systemConfig);
            vm.assertEq(bedrock.version(), "1.11.0");
            assert(bedrock.owner() == finalSystemOwner);
            assert(bedrock.overhead() == 188);
            assert(bedrock.scalar() == 684_000);
            assert(bedrock.batcherHash() == bytes32(uint256(uint160(batchSender))));
            assert(bedrock.gasLimit() == buildCfg.l2GasLimit);
        } else {
            SystemConfig granite = SystemConfig(builts.systemConfig);
            vm.assertEq(granite.version(), "2.2.0");
            assert(granite.owner() == finalSystemOwner);
            assert(granite.overhead() == 188);
            assert(granite.scalar() == 684_000);
            assert(granite.batcherHash() == bytes32(uint256(uint160(batchSender))));
            assert(granite.gasLimit() == buildCfg.l2GasLimit);
        }

        // resourceConfig
        {
            bytes memory _calldata = abi.encodeWithSelector(BedrockSystemConfig.resourceConfig.selector);
            (bool success, bytes memory returndata) = builts.systemConfig.call(_calldata);
            ResourceMetering.ResourceConfig memory resCfg = abi.decode(returndata, (ResourceMetering.ResourceConfig));
            assert(success);
            assert(resCfg.maxResourceLimit == 20_000_000);
            assert(resCfg.elasticityMultiplier == 10);
            assert(resCfg.baseFeeMaxChangeDenominator == 8);
            assert(resCfg.minimumBaseFee == 1 gwei);
            assert(resCfg.systemTxMaxGas == 1_000_000);
            assert(resCfg.maximumBaseFee == type(uint128).max);
        }
    }

    function _assert_L1CrossDomainMessenger(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockL1CrossDomainMessenger bedrock = BedrockL1CrossDomainMessenger(builts.l1CrossDomainMessenger);
            vm.assertEq(bedrock.version(), "1.8.0");
            assert(bedrock.OTHER_MESSENGER() == 0x4200000000000000000000000000000000000007);
            assert(bedrock.PORTAL() == builts.oasysPortal);
        } else {
            L1CrossDomainMessenger granite = L1CrossDomainMessenger(builts.l1CrossDomainMessenger);
            vm.assertEq(granite.version(), "2.4.0");
            assert(address(granite.otherMessenger()) == 0x4200000000000000000000000000000000000007);
            assert(address(granite.portal()) == builts.oasysPortal);
            assert(address(granite.superchainConfig()) == superchainConfigProxy);
            assert(address(granite.systemConfig()) == builts.systemConfig);
        }

        // successfulMessages
        {
            bytes32 mapKey = bytes32("successfulMessages");
            bytes memory _calldata =
                abi.encodeWithSelector(BedrockL1CrossDomainMessenger.successfulMessages.selector, mapKey);

            bytes32 rootSlot = bytes32(
                uint256(
                    1 // CrossDomainMessengerLegacySpacer0 + Initializable
                        + 202 // CrossDomainMessengerLegacySpacer1
                )
            );
            bytes32 valueSlot = keccak256(abi.encodePacked(mapKey, rootSlot));

            // set to false
            vm.store(builts.l1CrossDomainMessenger, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.l1CrossDomainMessenger.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == false);

            // set to true
            vm.store(builts.l1CrossDomainMessenger, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.l1CrossDomainMessenger.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == true);
        }

        // failedMessages
        {
            bytes32 mapKey = bytes32("failedMessages");
            bytes memory _calldata =
                abi.encodeWithSelector(BedrockL1CrossDomainMessenger.failedMessages.selector, mapKey);

            bytes32 rootSlot = bytes32(
                uint256(
                    1 // CrossDomainMessengerLegacySpacer0 + Initializable
                        + 202 // CrossDomainMessengerLegacySpacer1()
                        + 1 // CrossDomainMessenger:successfulMessages
                        + 1 // CrossDomainMessenger:xDomainMsgSender
                        + 1 // CrossDomainMessenger:msgNonce
                )
            );
            bytes32 valueSlot = keccak256(abi.encodePacked(mapKey, rootSlot));

            // set to false
            vm.store(builts.l1CrossDomainMessenger, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.l1CrossDomainMessenger.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == false);

            // set to true
            vm.store(builts.l1CrossDomainMessenger, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.l1CrossDomainMessenger.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == true);
        }
    }

    function _assert_L1StandardBridge(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockL1StandardBridge bedrock = BedrockL1StandardBridge(builts.l1StandardBridge);
            vm.assertEq(bedrock.version(), "1.5.0");
            assert(bedrock.MESSENGER() == builts.l1CrossDomainMessenger);
            assert(bedrock.OTHER_BRIDGE() == 0x4200000000000000000000000000000000000010);
        } else {
            L1StandardBridge granite = L1StandardBridge(payable(builts.l1StandardBridge));
            vm.assertEq(granite.version(), "2.2.0");
            assert(address(granite.messenger()) == builts.l1CrossDomainMessenger);
            assert(address(granite.otherBridge()) == 0x4200000000000000000000000000000000000010);
            assert(address(granite.superchainConfig()) == superchainConfigProxy);
            assert(address(granite.systemConfig()) == builts.systemConfig);
        }

        // deposits / mapping(address => mapping(address => uint256))
        {
            address token = address(1);
            address holder = address(2);
            bytes memory _calldata = abi.encodeWithSelector(BedrockL1StandardBridge.deposits.selector, token, holder);

            bytes32 rootSlot = bytes32(uint256(2)); // StandardBridge(2)
            bytes32 valueSlot = keccak256(abi.encodePacked(uint256(uint160(token)), rootSlot));
            valueSlot = keccak256(abi.encodePacked(uint256(uint160(holder)), valueSlot));

            // set to 0
            vm.store(builts.l1StandardBridge, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.l1StandardBridge.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (uint256)) == 0);

            // set to 1
            vm.store(builts.l1StandardBridge, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.l1StandardBridge.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (uint256)) == 1);
        }
    }

    function _assert_L1ERC721Bridge(Upgrade _upgrade) internal {
        if (_upgrade == Upgrade.BEDROCK) {
            BedrockOasysL1ERC721Bridge bedrock = BedrockOasysL1ERC721Bridge(builts.l1ERC721Bridge);
            vm.assertEq(bedrock.version(), "1.5.0");
            assert(bedrock.MESSENGER() == builts.l1CrossDomainMessenger);
            assert(bedrock.OTHER_BRIDGE() == 0x6200000000000000000000000000000000000001);
        } else {
            OasysL1ERC721Bridge granite = OasysL1ERC721Bridge(builts.l1ERC721Bridge);
            vm.assertEq(granite.version(), "2.1.0");
            assert(address(granite.messenger()) == builts.l1CrossDomainMessenger);
            assert(address(granite.otherBridge()) == 0x6200000000000000000000000000000000000001);
            assert(address(granite.l2ERC721Bridge()) == 0x6200000000000000000000000000000000000001);
            assert(address(granite.superchainConfig()) == superchainConfigProxy);

            // Check if storage gaps are reserved in multiples of 50
            {
                // NOTE: Incorrect slot calculation in official Optimism implementation
                // OasysERC721BridgeLegacySpacer(50) + Initializable(2byte) + ERC721Bridge(30byte+2+46) = 99
                bytes32 slot = bytes32(uint256(50 + 3 + 46));
                bytes32 value = vm.load(builts.l1ERC721Bridge, slot);
                assert(value == bytes32(uint256(uint160(superchainConfigProxy))));
            }
        }

        // deposits / mapping(address => mapping(address => mapping(uint256 => bool)))
        {
            address token = address(1);
            address holder = address(2);
            uint256 tokenId = 3;
            bytes memory _calldata =
                abi.encodeWithSelector(BedrockOasysL1ERC721Bridge.deposits.selector, token, holder, tokenId);

            bytes32 rootSlot = bytes32(uint256(2)); // OasysERC721BridgeLegacySpacer(2)
            bytes32 valueSlot = keccak256(abi.encodePacked(uint256(uint160(token)), rootSlot));
            valueSlot = keccak256(abi.encodePacked(uint256(uint160(holder)), valueSlot));
            valueSlot = keccak256(abi.encodePacked(tokenId, valueSlot));

            // set to false
            vm.store(builts.l1ERC721Bridge, valueSlot, bytes32(uint256(0)));
            (bool success, bytes memory returndata) = builts.l1ERC721Bridge.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == false);

            // set to true
            vm.store(builts.l1ERC721Bridge, valueSlot, bytes32(uint256(1)));
            (success, returndata) = builts.l1ERC721Bridge.call(_calldata);
            assert(success);
            assert(abi.decode(returndata, (bool)) == true);
        }
    }

    function _add_BedrockToGranite_Implementer() internal returns (BedrockToGranite bedrockToGranite) {
        vm.prank(deployer);
        bedrockToGranite = new BedrockToGranite({
            _superchainConfig: address(new SuperchainConfig()),
            _optimismPortal: address(new OasysPortal()),
            _l2OutputOracle: address(new OasysL2OutputOracle()),
            _systemConfig: address(new SystemConfig()),
            _l1CrossDomainMessenger: address(new L1CrossDomainMessenger()),
            _l1StandardBridge: address(new L1StandardBridge()),
            _l1ERC721Bridge: address(new OasysL1ERC721Bridge())
        });

        vm.prank(deployer);
        upgradeManager.addNextImplementer(bedrockToGranite);
    }

    function supportsInterface(bytes4 _interfaceId) public pure override(IERC165) returns (bool) {
        return _interfaceId == type(IUpgradeManager).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }
}
