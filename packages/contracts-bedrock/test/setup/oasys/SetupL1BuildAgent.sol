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

import { Constants } from "src/libraries/Constants.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { ProtocolVersions } from "src/L1/ProtocolVersions.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { OasysL2OutputOracleVerifier } from "src/oasys/L1/rollup/OasysL2OutputOracleVerifier.sol";

import { Path } from "scripts/oasys/L1/build/_path.sol";
import { Deploy } from "scripts/oasys/L1/build/Deploy.s.sol";

import { BuiltInContracts } from "test/setup/oasys/BuiltInContracts.sol";

contract SetupL1BuildAgent is Test {
    using stdJson for string;

    struct Deployment {
        // Build config
        uint256 chainId;
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
        AddressManager addressManager;
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

    // Dependency contracts
    IPermissionedContractFactory permissionedFactory;
    OasysL2OutputOracleVerifier l2OracleVerifier;

    /// L1 Build contracts
    L1BuildAgent l1Agent;
    L1BuildDeposit l1Deposit;

    /// @dev Default deployment L2
    Deployment deployment;

    function setUp() public virtual {
        _addBalanceToTestWallets();

        permissionedFactory = _deployPermissionedContractFactory(msg.sender);

        (l1Agent, l1Deposit, l2OracleVerifier) = _deployL1BuildContracts(permissionedFactory);

        vm.prank(depositor);
        l1Deposit.deposit{ value: 1 ether }(builder);

        vm.prank(builder);
        deployment = _runL1BuildAgent(
            5555,
            IL1BuildAgent.BuildConfig({
                finalSystemOwner: finalOwner,
                l2OutputOracleProposer: proposer,
                l2OutputOracleChallenger: challenger,
                batchSenderAddress: batcher,
                l2BlockTime: 5,
                l2GasLimit: 50_000_000,
                l2OutputOracleSubmissionInterval: 50,
                finalizationPeriodSeconds: 5 days,
                l2OutputOracleStartingBlockNumber: 500,
                l2OutputOracleStartingTimestamp: block.timestamp
            })
        );

        console.log("\nWallets");
        console.log("alice      : %s", alice);
        console.log("bob        : %s", bob);
        console.log("depositor  : %s", depositor);
        console.log("builder    : %s", builder);
        console.log("finalOwner : %s", finalOwner);
        console.log("proposer   : %s", proposer);
        console.log("challenger : %s", challenger);
        console.log("batcher    : %s", batcher);

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
        vm.setEnv("SALT", salt);
        vm.setEnv("PERMISSIONED_FACTORY", vm.toString(address(factory)));
        vm.setEnv("LEGACY_AGENT", vm.toString(address(0)));
        vm.setEnv("LEGACY_DEPOSIT", vm.toString(address(0)));

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
        IL1BuildAgent.BuildConfig memory cfg
    )
        internal
        returns (Deployment memory)
    {
        (
            address proxyAdmin,
            address[7] memory proxys,
            address[7] memory impls,
            address batchInbox,
            address addressManager
        ) = l1Agent.build(chainId, cfg);

        return Deployment({
            // Build config
            chainId: chainId,
            buildCfg: cfg,
            // Deployed proxies
            portal: OasysPortal(payable(proxys[0])),
            l2Oracle: OasysL2OutputOracle(proxys[1]),
            systemConfig: SystemConfig(proxys[2]),
            l1Messenger: L1CrossDomainMessenger(proxys[3]),
            l1ERC20Bridge: L1StandardBridge(payable(proxys[4])),
            l1ERC721Bridge: L1ERC721Bridge(proxys[5]),
            protocolVersions: ProtocolVersions(proxys[6]),
            // Deployed implementations
            proxyAdmin: ProxyAdmin(proxyAdmin),
            addressManager: AddressManager(addressManager),
            portalImpl: OasysPortal(payable(impls[0])),
            l2OracleImpl: OasysL2OutputOracle(impls[1]),
            systemConfigImpl: SystemConfig(impls[2]),
            l1MessengerImpl: L1CrossDomainMessenger(impls[3]),
            l1ERC20BridgeImpl: L1StandardBridge(payable(impls[4])),
            l1ERC721BridgeImpl: L1ERC721Bridge(impls[5]),
            protocolVersionsImpl: ProtocolVersions(impls[6]),
            // Misc
            batchInbox: batchInbox
        });
    }
}
