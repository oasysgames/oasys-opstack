// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Forge testing utilities
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";

// Universal contracts and interfaces
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";

// Builder interfaces
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";

// Target contract and closed implementations
import { L1CloseAgent } from "src/oasys/L1/close/L1CloseAgent.sol";
import { ClosedL1StandardBridge } from "src/oasys/L1/close/ClosedL1StandardBridge.sol";
import { ClosedL1ERC721Bridge } from "src/oasys/L1/close/ClosedL1ERC721Bridge.sol";
import { ClosedL1CrossDomainMessenger } from "src/oasys/L1/close/ClosedL1CrossDomainMessenger.sol";

// Test setup
import { SetupL1BuildAgent } from "../upgrade/SetupBedrock.sol";

/// @title L1CloseAgent_Test
/// @notice Tests for L1CloseAgent.close.
contract L1CloseAgent_Test is Test {
    address public deployer;
    address public depositor;
    address public verseBuilder;
    address public finalSystemOwner;
    address public l2ooProposer;
    address public l2ooChallenger;
    address public batchSender;
    address public p2pSequencer;
    address public messageRelayer;

    uint256 public chainId = 4200;
    IL1BuildAgent public buildAgent;
    IL1BuildDeposit public buildDeposit;
    L1CloseAgent public l1CloseAgent;
    IL1BuildAgent.BuildConfig public buildCfg;
    IL1BuildAgent.BuiltAddressList public builts;
    ProxyAdmin public proxyAdmin;

    function setUp() public virtual {
        deployer = makeAddr("deployer");
        depositor = makeAddr("depositor");
        verseBuilder = makeAddr("verseBuilder");
        finalSystemOwner = makeAddr("finalSystemOwner");
        l2ooProposer = makeAddr("l2ooProposer");
        l2ooChallenger = makeAddr("l2ooChallenger");
        batchSender = makeAddr("batchSender");
        p2pSequencer = makeAddr("p2pSequencer");
        messageRelayer = makeAddr("messageRelayer");

        // Deploy L1BuildAgent and L1BuildDeposit via SetupBedrock
        vm.prank(deployer);
        (buildAgent, buildDeposit) = (new SetupL1BuildAgent()).deploy();

        // Deploy closed implementations and L1CloseAgent
        ClosedL1StandardBridge closedL1StandardBridge = new ClosedL1StandardBridge(buildAgent);
        ClosedL1ERC721Bridge closedL1ERC721Bridge = new ClosedL1ERC721Bridge(buildAgent);
        ClosedL1CrossDomainMessenger closedL1CrossDomainMessenger = new ClosedL1CrossDomainMessenger();

        vm.prank(deployer);
        l1CloseAgent = new L1CloseAgent(
            buildAgent,
            address(closedL1StandardBridge),
            address(closedL1ERC721Bridge),
            address(closedL1CrossDomainMessenger)
        );

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

        vm.deal(depositor, 1 ether);
        vm.prank(depositor);
        buildDeposit.deposit{ value: 1 ether }({ _builder: verseBuilder });

        vm.prank(verseBuilder);
        (builts,) = buildAgent.build({ chainId: chainId, cfg: buildCfg });
        proxyAdmin = ProxyAdmin(builts.proxyAdmin);

        // Transfer ProxyAdmin to L1CloseAgent so close() can upgrade
        vm.prank(finalSystemOwner);
        proxyAdmin.transferOwnership(address(l1CloseAgent));
    }

    function test_close_success() public {
        assert(proxyAdmin.owner() == address(l1CloseAgent));

        vm.prank(finalSystemOwner);
        l1CloseAgent.close(chainId);

        // ProxyAdmin ownership returned to final system owner
        assert(proxyAdmin.owner() == finalSystemOwner);

        // Bridges upgraded to closed implementations
        assert(proxyAdmin.getProxyImplementation(builts.l1StandardBridge) == l1CloseAgent.CLOSED_L1_STANDARD_BRIDGE());
        assert(proxyAdmin.getProxyImplementation(builts.l1ERC721Bridge) == l1CloseAgent.CLOSED_L1_ERC721_BRIDGE());
        assert(
            proxyAdmin.getProxyImplementation(builts.l1CrossDomainMessenger)
                == l1CloseAgent.CLOSED_L1_CROSS_DOMAIN_MESSENGER()
        );
    }

    function test_close_revert_notFinalSystemOwner() public {
        vm.prank(verseBuilder);
        vm.expectRevert("not final system owner");
        l1CloseAgent.close(chainId);
    }

    function test_close_revert_notTransferredAdmin() public {
        // Transfer ProxyAdmin back to finalSystemOwner so L1CloseAgent is no longer owner
        vm.prank(address(l1CloseAgent));
        proxyAdmin.transferOwnership(finalSystemOwner);

        vm.prank(finalSystemOwner);
        vm.expectRevert("not transferred admin");
        l1CloseAgent.close(chainId);
    }

    function test_close_revert_invalidChainId() public {
        vm.prank(finalSystemOwner);
        vm.expectRevert("invalid chain id");
        l1CloseAgent.close(chainId + 1);
    }
}
