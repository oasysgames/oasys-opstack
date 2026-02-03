// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Forge testing utilities
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";

// Universal contracts and interfaces
import { Proxy } from "src/universal/Proxy.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";

// Builder interfaces
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";

// Target contract and closed implementations
import { L1CloseAgent } from "src/oasys/L1/close/L1CloseAgent.sol";
import { ClosedL1StandardBridge } from "src/oasys/L1/close/ClosedL1StandardBridge.sol";
import { ClosedL1ERC721Bridge } from "src/oasys/L1/close/ClosedL1ERC721Bridge.sol";
import { ClosedL1CrossDomainMessenger } from "src/oasys/L1/close/ClosedL1CrossDomainMessenger.sol";
import { ClosedOptimismPortal } from "src/oasys/L1/close/ClosedOptimismPortal.sol";

// Bridges (for deposit/withdraw calls)
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { ERC721Bridge } from "src/universal/ERC721Bridge.sol";

// Test mocks
import { TestERC20 } from "test/mocks/TestERC20.sol";
import { TestERC721 } from "test/mocks/TestERC721.sol";

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

        // Deploy closed implementations and L1CloseAgent (after build so we have portal proxy for close())
        ClosedL1StandardBridge closedL1StandardBridge = new ClosedL1StandardBridge(buildAgent);
        ClosedL1ERC721Bridge closedL1ERC721Bridge = new ClosedL1ERC721Bridge(buildAgent);
        ClosedL1CrossDomainMessenger closedL1CrossDomainMessenger = new ClosedL1CrossDomainMessenger();
        ClosedOptimismPortal closedOptimismPortal = new ClosedOptimismPortal(buildAgent);

        L1CloseAgent l1CloseAgentImpl = new L1CloseAgent(
            buildAgent,
            address(closedL1StandardBridge),
            address(closedL1ERC721Bridge),
            address(closedL1CrossDomainMessenger),
            address(closedOptimismPortal)
        );

        Proxy l1CloseAgentProxy = new Proxy(deployer);
        vm.prank(deployer);
        l1CloseAgentProxy.upgradeTo(address(l1CloseAgentImpl));
        l1CloseAgent = L1CloseAgent(payable(address(l1CloseAgentProxy)));

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

        // make sure portal is paused
        assert(ClosedOptimismPortal(payable(builts.oasysPortal)).paused());
    }

    /// @notice Complex scenario: before close do depositETH, depositERC20, bridgeERC721;
    ///         after close confirm deposits revert and final system owner can withdraw.
    function test_close_scenario() public {
        // --- Deploy test tokens ---
        TestERC20 erc20 = new TestERC20();
        TestERC721 erc721 = new TestERC721();
        address l2TokenDummy = address(0x1234); // no L2 in test; dummy is ok for depositERC20
        uint256 erc20Amount = 100e18;
        uint256 nftTokenId = 1;

        erc20.mint(depositor, erc20Amount);
        erc721.mint(depositor, nftTokenId);

        vm.deal(depositor, 2 ether);
        address recipient = makeAddr("withdrawRecipient");

        L1StandardBridge standardBridge = L1StandardBridge(payable(builts.l1StandardBridge));
        ERC721Bridge erc721Bridge = ERC721Bridge(payable(builts.l1ERC721Bridge));

        // --- Before close: deposits must succeed ---
        vm.prank(depositor);
        standardBridge.depositETH{ value: 1 ether }(200_000, "");
        assertEq(address(builts.oasysPortal).balance, 1 ether, "portal must hold deposited ETH");

        vm.prank(depositor);
        erc20.approve(address(standardBridge), erc20Amount);
        vm.prank(depositor);
        standardBridge.depositERC20(address(erc20), l2TokenDummy, erc20Amount, 200_000, "");
        assertEq(erc20.balanceOf(address(standardBridge)), erc20Amount, "bridge must hold deposited ERC20");

        vm.prank(depositor);
        erc721.approve(address(erc721Bridge), nftTokenId);
        vm.prank(depositor);
        erc721Bridge.bridgeERC721(address(erc721), l2TokenDummy, nftTokenId, 200_000, "");
        assertEq(erc721.balanceOf(address(erc721Bridge)), 1, "bridge must hold deposited ERC721");

        // --- Close the chain ---
        uint256 finalSystemOwnerEthBefore = finalSystemOwner.balance;
        vm.prank(finalSystemOwner);
        l1CloseAgent.close(chainId);

        // --- After close: deposit/bridge must revert ---
        vm.prank(depositor);
        vm.expectRevert("bridge is closed");
        standardBridge.depositETH{ value: 1 ether }(200_000, "");
        vm.prank(depositor);
        vm.expectRevert("bridge is closed");
        standardBridge.depositERC20(address(erc20), l2TokenDummy, erc20Amount, 200_000, "");

        vm.prank(depositor);
        vm.expectRevert("bridge is closed");
        erc721Bridge.bridgeERC721(address(erc721), l2TokenDummy, nftTokenId, 200_000, "");

        // --- Final system owner holds ETH and can withdraw ERC20 and ERC721 from closed bridges ---
        assertEq(address(builts.oasysPortal).balance, 0, "portal must hold no ETH");
        assertEq(
            finalSystemOwner.balance,
            finalSystemOwnerEthBefore + 1 ether,
            "ETH should be transferred to final system owner"
        );

        ClosedL1StandardBridge closedStandardBridge = ClosedL1StandardBridge(payable(builts.l1StandardBridge));
        ClosedL1ERC721Bridge closedErc721Bridge = ClosedL1ERC721Bridge(payable(builts.l1ERC721Bridge));

        vm.prank(finalSystemOwner);
        closedStandardBridge.withdrawERC20(chainId, address(erc20), recipient, erc20Amount);
        assertEq(erc20.balanceOf(recipient), erc20Amount, "withdrawERC20");

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = nftTokenId;
        vm.prank(finalSystemOwner);
        closedErc721Bridge.withdrawERC721(chainId, address(erc721), recipient, tokenIds);
        assertEq(erc721.ownerOf(nftTokenId), recipient, "withdrawERC721");
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
