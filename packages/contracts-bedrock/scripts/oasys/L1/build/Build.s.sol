// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { Executables } from "scripts/Executables.sol";
import { Path } from "./_path.sol";

contract Build is Script {
    using stdJson for string;

    /// @notice See:
    /// https://github.com/oasysgames/oasys-opstack/blob/5648932ac8a45598de70d857cc99c91a8ebce1fc/op-chain-ops/genesis/config.go
    struct DeployConfig {
        // FinalSystemOwner is the owner of the system on L1. Any L1 contract that is ownable has
        // this account set as its owner.
        address finalSystemOwner;
        // PortalGuardian represents the GUARDIAN account in the OptimismPortal. Has the ability to pause withdrawals.
        // Set the same value as the finalSystemOwner.
        address portalGuardian;
        // L1StartingBlockTag is used to fill in the storage of the L1Block info predeploy. The rollup
        // config script uses this to fill the L1 genesis info for the rollup. The Output oracle deploy
        // script may use it if the L2 starting timestamp is nil, assuming the L2 genesis is set up
        // with this.
        // Set the block hash of latest - 1.
        // To be accurate, it's preferable to set the latest block hash.
        // However, the hash of the latest block cannot be determined during runtime,
        // necessitating the use of the previous block's hash.
        bytes32 l1StartingBlockTag;
        // L1ChainID is the chain ID of the L1 chain.
        uint256 l1ChainID;
        // L2ChainID is the chain ID of the L2 chain.
        uint256 l2ChainID;
        // L2BlockTime is the number of seconds between each L2 block.
        uint256 l2BlockTime;
        // Initial Gas Limit of L2 Genesis Block.
        // Set the same value as the L2 block gas limit.
        uint256 l2GenesisBlockGasLimit;
        // L2 Genesis Block Initial Gas Fee.
        // Set 0 to keep the gas fee zero.
        uint256 l2GenesisBlockBaseFeePerGas;
        // MaxSequencerDrift is the number of seconds after the L1 timestamp of the end of the
        // sequencing window that batches must be included, otherwise L2 blocks including
        // deposits are force included.
        // Set the same value as opstack mainnet.
        uint256 maxSequencerDrift;
        // SequencerWindowSize is the number of L1 blocks per sequencing window.
        // Set the same value as opstack mainnet.
        uint256 sequencerWindowSize;
        // ChannelTimeout is the number of L1 blocks that a frame stays valid when included in L1.
        // Set the same value as opstack mainnet.
        uint256 channelTimeout;
        // P2PSequencerAddress is the address of the key the sequencer uses to sign blocks on the P2P layer.
        address p2pSequencerAddress;
        // BatchInboxAddress is the L1 account that batches are sent to.
        // The unique address is generated during the build process.
        address batchInboxAddress;
        // BatchSenderAddress represents the initial sequencer account that authorizes batches.
        // Transactions sent from this account to the batch inbox address are considered valid.
        address batchSenderAddress;
        // Used for calculate the next checkpoint block number, in Opstack case, 120 is set in testnet. 2s(default l2
        // block time) * 120 = 240s. submit l2 root every 240s. it means l2->l1 withdrawal will be available every 240s.
        // Value: 120
        uint256 l2OutputOracleSubmissionInterval;
        // L2OutputOracleStartingBlockNumber is the starting block number for the L2OutputOracle.
        // Must be greater than or equal to the first Bedrock block. The first L2 output will correspond
        // to this value plus the submission interval.
        // Set 0, if building from the genesis block. (no data migration)
        // Set the last block number +1, if building from the last block. (with data migration)
        uint256 l2OutputOracleStartingBlockNumber;
        // L2OutputOracleStartingTimestamp is the starting timestamp for the L2OutputOracle.
        // MUST be the same as the timestamp of the L2OO start block.
        // Set runtime block timestamp during the build process.
        uint256 l2OutputOracleStartingTimestamp;
        // L2OutputOracleProposer is the address of the account that proposes L2 outputs.
        address l2OutputOracleProposer;
        // L2OutputOracleChallenger is the address of the account that challenges L2 outputs.
        address l2OutputOracleChallenger;
        // MessageRelayer is the address of message-relayer finalizer.
        address messageRelayer;
        // FinalizationPeriodSeconds represents the number of seconds before an output is considered
        // finalized. This impacts the amount of time that withdrawals take to finalize and is
        // generally set to 1 week.
        uint256 finalizationPeriodSeconds;
        // ProxyAdminOwner represents the owner of the ProxyAdmin predeploy on L2.
        // Set the same value as the finalSystemOwner.
        address proxyAdminOwner;
        // BaseFeeVaultRecipient represents the recipient of fees accumulated in the BaseFeeVault.
        // Can be an account on L1 or L2, depending on the BaseFeeVaultWithdrawalNetwork value.
        // Set the same value as the finalSystemOwner.
        address baseFeeVaultRecipient;
        // L1FeeVaultRecipient represents the recipient of fees accumulated in the L1FeeVault.
        // Can be an account on L1 or L2, depending on the L1FeeVaultWithdrawalNetwork value.
        // Set the same value as the finalSystemOwner.
        address l1FeeVaultRecipient;
        // SequencerFeeVaultRecipient represents the recipient of fees accumulated in the SequencerFeeVault.
        // Can be an account on L1 or L2, depending on the SequencerFeeVaultWithdrawalNetwork value.
        // Set the same value as the finalSystemOwner.
        address sequencerFeeVaultRecipient;
        // BaseFeeVaultMinimumWithdrawalAmount represents the minimum withdrawal amount for the BaseFeeVault.
        // Set as 10 ether.
        uint256 baseFeeVaultMinimumWithdrawalAmount;
        // L1FeeVaultMinimumWithdrawalAmount represents the minimum withdrawal amount for the L1FeeVault.
        // Set as 10 ether.
        uint256 l1FeeVaultMinimumWithdrawalAmount;
        // SequencerFeeVaultMinimumWithdrawalAmount represents the minimum withdrawal amount for the SequencerFeeVault.
        // Set as 10 ether.
        uint256 sequencerFeeVaultMinimumWithdrawalAmount;
        // BaseFeeVaultWithdrawalNetwork represents the withdrawal network for the BaseFeeVault.
        // can only be 0 (L1) or 1 (L2)
        // Set 0 as same as opstack mainnet.
        uint256 baseFeeVaultWithdrawalNetwork;
        // L1FeeVaultWithdrawalNetwork represents the withdrawal network for the L1FeeVault.
        // can only be 0 (L1) or 1 (L2)
        // Set 0 as same as opstack mainnet.
        uint256 l1FeeVaultWithdrawalNetwork;
        // SequencerFeeVaultWithdrawalNetwork represents the withdrawal network for the SequencerFeeVault.
        // can only be 0 (L1) or 1 (L2)
        // Set 0 as same as opstack mainnet.
        uint256 sequencerFeeVaultWithdrawalNetwork;
        // GasPriceOracleOverhead represents the initial value of the gas overhead in the GasPriceOracle predeploy.
        // Set the same value as opstack mainnet.
        uint256 gasPriceOracleOverhead;
        // GasPriceOracleScalar represents the initial value of the gas scalar in the GasPriceOracle predeploy.
        // Set the same value as opstack mainnet.
        uint256 gasPriceOracleScalar;
        // EnableGovernance configures whether or not include governance token predeploy.
        // Set false, if you doesn't need governance token or migrate from the old network.
        // Set true, if you need governance token.
        bool enableGovernance;
        // GovernanceTokenSymbol represents the  ERC20 symbol of the GovernanceToken.
        string governanceTokenSymbol;
        // GovernanceTokenName represents the ERC20 name of the GovernanceToken
        string governanceTokenName;
        // GovernanceTokenOwner represents the owner of the GovernanceToken. Has the ability
        // to mint and burn tokens.
        address governanceTokenOwner;
        // L2GenesisRegolithTimeOffset is the number of seconds after genesis block that Regolith hard fork activates.
        // Set it to 0 to activate at genesis. Nil to disable Regolith.
        uint256 l2GenesisRegolithTimeOffset;
        // l2GenesisCanyonTimeOffset is the number of seconds after genesis block that Canyon hard fork activates.
        // Set it to 0 to activate at genesis. Nil to disable Canyon.
        uint256 l2GenesisCanyonTimeOffset;
        // EIP1559Denominator is the denominator of EIP1559 base fee market.
        // Set the default value of op-chain-ops/genesis/genesis.go
        // https://github.com/oasysgames/oasys-opstack/blob/5648932ac8a45598de70d857cc99c91a8ebce1fc/op-chain-ops/genesis/genesis.go#L32
        uint256 eip1559Denominator;
        // EIP1559DenominatorCanyon is the denominator of EIP1559 base fee market when Canyon is active.
        // The opstack mainnet activated Canyon at 1704992401 (Thu, 2024-01-11 at 17:00:01 UTC)
        // https://docs.optimism.io/builders/node-operators/network-upgrades/overview
        // Set the default value of op-chain-ops/genesis/genesis.go
        // https://github.com/oasysgames/oasys-opstack/blob/5648932ac8a45598de70d857cc99c91a8ebce1fc/op-chain-ops/genesis/genesis.go#L36
        uint256 eip1559DenominatorCanyon;
        // EIP1559Elasticity is the elasticity of the EIP1559 fee market.
        // Set the default value of op-chain-ops/genesis/genesis.go
        // https://github.com/oasysgames/oasys-opstack/blob/5648932ac8a45598de70d857cc99c91a8ebce1fc/op-chain-ops/genesis/genesis.go#L40
        uint256 eip1559Elasticity;
        // SystemConfigStartBlock represents the block at which the op-node should start syncing
        // from. It is an override to set this value on legacy networks where it is not set by
        // default. It can be removed once all networks have this value set in their storage.
        // Set the same height as l1StartingBlockTag.
        uint256 systemConfigStartBlock;
        // RequiredProtocolVersion indicates the protocol version that
        // nodes are required to adopt, to stay in sync with the network.
        // used to manage superchain protocol version information.
        // Set 0, as we don't support superchain yet.
        bytes32 requiredProtocolVersion;
        // RequiredProtocolVersion indicates the protocol version that
        // nodes are recommended to adopt, to stay in sync with the network.
        // Set 0, as we don't support superchain yet.
        bytes32 recommendedProtocolVersion;
        // L1StandardBridgeProxy represents the address of the L1StandardBridgeProxy on L1 and is used
        // as part of building the L2 genesis state.
        // Automatically set during the build process.
        address l1StandardBridgeProxy;
        // L1CrossDomainMessengerProxy represents the address of the L1CrossDomainMessengerProxy on L1 and is used
        // as part of building the L2 genesis state.
        // Automatically set during the build process.
        address l1CrossDomainMessengerProxy;
        // L1ERC721BridgeProxy represents the address of the L1ERC721Bridge on L1 and is used
        // as part of building the L2 genesis state.
        // Automatically set during the build process.
        address l1ERC721BridgeProxy;
        // SystemConfigProxy represents the address of the SystemConfigProxy on L1 and is used
        // Automatically set during the build process.
        address systemConfigProxy;
        // OptimismPortalProxy represents the address of the OptimismPortalProxy on L1 and is used
        // as part of the derivation pipeline.
        // Automatically set during the build process.
        address optimismPortalProxy;
        // L1BlockTime is the number of seconds between each L1 block.
        uint256 l1BlockTime;
        // The timestamp for enabling the L2 zero-fee mode.
        uint256 l2ZeroFeeTime;
    }

    /// @notice Contracts Deployed on L1
    struct DeployedContract {
        address proxyAdmin;
        address optimismPortalProxy;
        address l2OutputOracleProxy;
        address systemConfigProxy;
        address l1CrossDomainMessengerProxy;
        address l1StandardBridgeProxy;
        address l1ERC721BridgeProxy;
        address protocolVersions;
        address addressManager;
        address batchInbox;
    }

    DeployConfig deployCfg;
    IL1BuildAgent.BuildConfig buildCfg;
    IL1BuildDeposit deposit;
    IL1BuildAgent agent;

    function setUp() public {
        // read build parameters from environment variables.
        address finalSystemOwner = vm.envAddress("FINAL_SYSTEM_OWNER");
        address p2pSequencer = vm.envAddress("P2P_SEQUENCER");
        address l2ooChallenger = vm.envAddress("L2OO_CHALLENGER");
        address l2ooProposer = vm.envAddress("L2OO_PROPOSER");
        address batchSender = vm.envAddress("BATCH_SENDER");
        address messageRelayer = vm.envAddress("MESSAGE_RELAYER");
        uint256 l2ChainId = vm.envUint("L2_CHAIN_ID");
        uint256 l1BlockTime = vm.envUint("L1_BLOCK_TIME");
        uint256 l2BlockTime = vm.envUint("L2_BLOCK_TIME");
        uint256 l2GasLimit = vm.envUint("L2_GAS_LIMIT");

        // construct a deployment configuration.
        deployCfg = DeployConfig({
            finalSystemOwner: finalSystemOwner,
            portalGuardian: finalSystemOwner,
            // ----
            l1StartingBlockTag: blockhash(block.number - 1),
            // ----
            l1ChainID: block.chainid,
            l2ChainID: l2ChainId,
            l2BlockTime: l2BlockTime,
            l1BlockTime: l1BlockTime,
            // ----
            maxSequencerDrift: 600,
            sequencerWindowSize: 3_600,
            channelTimeout: 300,
            // ----
            p2pSequencerAddress: p2pSequencer,
            batchSenderAddress: batchSender,
            // ----
            l2OutputOracleSubmissionInterval: vm.envUint("OUTPUT_ORACLE_SUBMISSION_INTERVAL"),
            l2OutputOracleStartingBlockNumber: vm.envUint("OUTPUT_ORACLE_STARTING_BLOCK_NUMBER"),
            l2OutputOracleStartingTimestamp: vm.envUint("OUTPUT_ORACLE_STARTING_TIMESTAMP"),
            // ----
            l2OutputOracleProposer: l2ooProposer,
            l2OutputOracleChallenger: l2ooChallenger,
            // ----
            messageRelayer: messageRelayer,
            // ----
            finalizationPeriodSeconds: vm.envUint("FINALIZATION_PERIOD_SECONDS"),
            // ----
            proxyAdminOwner: finalSystemOwner,
            baseFeeVaultRecipient: finalSystemOwner,
            l1FeeVaultRecipient: finalSystemOwner,
            sequencerFeeVaultRecipient: finalSystemOwner,
            // ----
            baseFeeVaultMinimumWithdrawalAmount: 10 ether,
            l1FeeVaultMinimumWithdrawalAmount: 10 ether,
            sequencerFeeVaultMinimumWithdrawalAmount: 10 ether,
            baseFeeVaultWithdrawalNetwork: 0,
            l1FeeVaultWithdrawalNetwork: 0,
            sequencerFeeVaultWithdrawalNetwork: 0,
            // ----
            gasPriceOracleOverhead: 188,
            gasPriceOracleScalar: 684000,
            // ----
            enableGovernance: vm.envOr("ENABLE_GOVERNANCE", false),
            governanceTokenSymbol: vm.envString("GOVERNANCE_TOKEN_NAME"),
            governanceTokenName: vm.envString("GOVERNANCE_TOKEN_SYMBOL"),
            governanceTokenOwner: finalSystemOwner,
            // ----
            l2GenesisBlockGasLimit: l2GasLimit,
            l2GenesisBlockBaseFeePerGas: 0,
            l2GenesisRegolithTimeOffset: 0,
            l2GenesisCanyonTimeOffset: 0,
            // ----
            eip1559Denominator: 50,
            eip1559DenominatorCanyon: 250,
            eip1559Elasticity: 10, // OP Mainnet is 6.
            // ----
            systemConfigStartBlock: block.number - 1,
            // ----
            requiredProtocolVersion: bytes32(0),
            recommendedProtocolVersion: bytes32(0),
            // ----
            l2ZeroFeeTime: vm.envOr("ENABLE_L2_ZERO_FEE", false) ? block.timestamp : 0,
            // set later.
            batchInboxAddress: address(0),
            l1StandardBridgeProxy: address(0),
            l1CrossDomainMessengerProxy: address(0),
            l1ERC721BridgeProxy: address(0),
            systemConfigProxy: address(0),
            optimismPortalProxy: address(0)
        });

        // construct a build configuration.
        buildCfg = IL1BuildAgent.BuildConfig({
            finalSystemOwner: deployCfg.finalSystemOwner,
            l2OutputOracleProposer: deployCfg.l2OutputOracleProposer,
            l2OutputOracleChallenger: deployCfg.l2OutputOracleChallenger,
            batchSenderAddress: deployCfg.batchSenderAddress,
            p2pSequencerAddress: deployCfg.p2pSequencerAddress,
            messageRelayer: deployCfg.messageRelayer,
            l2BlockTime: deployCfg.l2BlockTime,
            l2GasLimit: uint64(deployCfg.l2GenesisBlockGasLimit),
            l2OutputOracleSubmissionInterval: deployCfg.l2OutputOracleSubmissionInterval,
            finalizationPeriodSeconds: deployCfg.finalizationPeriodSeconds,
            l2OutputOracleStartingBlockNumber: deployCfg.l2OutputOracleStartingBlockNumber,
            l2OutputOracleStartingTimestamp: deployCfg.l2OutputOracleStartingTimestamp
        });

        // create a directory for output files.
        vm.createDir({ path: Path.buildLatestOutDir(), recursive: true });
        vm.createDir({ path: Path.buildRunOutDir(), recursive: true });

        // read the L1BuildDeposit address, which has been deployed on L1, from the output directory.
        deposit = _readDeployedL1BuildDeposit();
        console.log("L1BuildDeposit: %s", address(deposit));

        // read the L1BuildAgent address, which has been deployed on L1, from the output directory.
        agent = _readDeployedL1BuildAgent();
        console.log("L1BuildAgent: %s", address(agent));
    }

    function run() public {
        vm.startBroadcast();
        // deposit 1 eth to the L1BuildDeposit contract.
        deposit.deposit{ value: 1 ether }(msg.sender);

        // build L2.
        (IL1BuildAgent.BuiltAddressList memory results,) = agent.build(deployCfg.l2ChainID, buildCfg);
        vm.stopBroadcast();

        // set deployed addresses
        deployCfg.optimismPortalProxy = results.oasysPortal;
        deployCfg.systemConfigProxy = results.systemConfig;
        deployCfg.l1CrossDomainMessengerProxy = results.l1CrossDomainMessenger;
        deployCfg.l1StandardBridgeProxy = results.l1StandardBridge;
        deployCfg.l1ERC721BridgeProxy = results.l1ERC721Bridge;
        deployCfg.batchInboxAddress = results.batchInbox;

        // output opstack configuration files.
        string memory deployCfgJson = _deployConfigJson("DeployConfig");
        string memory addressesJson = _addressesJson(
            "deployed", results.proxyAdmin, results.oasysL2OutputOracle, address(0), results.protocolVersions
        );

        // output to the `./tmp/L1BuildAgent/Build/latest` directory
        _writeJson(deployCfgJson, Path.buildLatestOutDir(), "/deploy-config.json");
        _writeJson(addressesJson, Path.buildLatestOutDir(), "/addresses.json");

        // output to the `./tmp/L1BuildAgent/Build/run-{L1_BLOCK_NUM}` directory
        _writeJson(deployCfgJson, Path.buildRunOutDir(), "/deploy-config.json");
        _writeJson(addressesJson, Path.buildRunOutDir(), "/addresses.json");
    }

    function _readDeployedL1BuildDeposit() internal view returns (IL1BuildDeposit) {
        string memory json = vm.readFile(Path.deployLatestOutPath());
        return IL1BuildDeposit(stdJson.readAddress(json, "$.L1BuildDeposit"));
    }

    function _readDeployedL1BuildAgent() internal view returns (IL1BuildAgent) {
        string memory json = vm.readFile(Path.deployLatestOutPath());
        return IL1BuildAgent(stdJson.readAddress(json, "$.L1BuildAgent"));
    }

    function _writeJson(string memory json, string memory dir, string memory file) internal {
        string memory path = string.concat(dir, file);
        json.write(path);

        console.log("Output: %s", path);
    }

    function _toHexWithoutZeroPadding(uint256 u) internal returns (string memory) {
        if (u == 0) {
            return "0x0";
        }

        string[] memory cmd = new string[](3);
        cmd[0] = Executables.bash;
        cmd[1] = "-c";
        cmd[2] = string.concat(
            Executables.echo, " ", vm.toString(bytes32(u)), " | ", Executables.sed, " 's/^0x0\\{0,64\\}/0x/g'"
        );

        bytes memory result = vm.ffi(cmd);
        if (result.length % 2 == 0) {
            return vm.toString(result);
        }
        return string(result);
    }

    function _deployConfigJson(string memory json) internal returns (string memory out) {
        json.serialize("finalSystemOwner", deployCfg.finalSystemOwner);
        json.serialize("portalGuardian", deployCfg.portalGuardian);

        json.serialize("l1StartingBlockTag", deployCfg.l1StartingBlockTag);

        json.serialize("l1ChainID", deployCfg.l1ChainID);
        json.serialize("l2ChainID", deployCfg.l2ChainID);
        json.serialize("l2BlockTime", deployCfg.l2BlockTime);
        json.serialize("l1BlockTime", deployCfg.l1BlockTime);

        json.serialize("maxSequencerDrift", deployCfg.maxSequencerDrift);
        json.serialize("sequencerWindowSize", deployCfg.sequencerWindowSize);
        json.serialize("channelTimeout", deployCfg.channelTimeout);

        json.serialize("p2pSequencerAddress", deployCfg.p2pSequencerAddress);
        json.serialize("batchInboxAddress", deployCfg.batchInboxAddress);
        json.serialize("batchSenderAddress", deployCfg.batchSenderAddress);

        json.serialize("l2OutputOracleSubmissionInterval", deployCfg.l2OutputOracleSubmissionInterval);
        json.serialize("l2OutputOracleStartingBlockNumber", deployCfg.l2OutputOracleStartingBlockNumber);
        json.serialize("l2OutputOracleStartingTimestamp", deployCfg.l2OutputOracleStartingTimestamp);

        json.serialize("l2OutputOracleProposer", deployCfg.l2OutputOracleProposer);
        json.serialize("l2OutputOracleChallenger", deployCfg.l2OutputOracleChallenger);

        json.serialize("finalizationPeriodSeconds", deployCfg.finalizationPeriodSeconds);

        json.serialize("proxyAdminOwner", deployCfg.proxyAdminOwner);
        json.serialize("baseFeeVaultRecipient", deployCfg.baseFeeVaultRecipient);
        json.serialize("l1FeeVaultRecipient", deployCfg.l1FeeVaultRecipient);
        json.serialize("sequencerFeeVaultRecipient", deployCfg.sequencerFeeVaultRecipient);

        json.serialize(
            "baseFeeVaultMinimumWithdrawalAmount",
            _toHexWithoutZeroPadding(deployCfg.baseFeeVaultMinimumWithdrawalAmount)
        );
        json.serialize(
            "l1FeeVaultMinimumWithdrawalAmount", _toHexWithoutZeroPadding(deployCfg.l1FeeVaultMinimumWithdrawalAmount)
        );
        json.serialize(
            "sequencerFeeVaultMinimumWithdrawalAmount",
            _toHexWithoutZeroPadding(deployCfg.sequencerFeeVaultMinimumWithdrawalAmount)
        );
        json.serialize("baseFeeVaultWithdrawalNetwork", deployCfg.baseFeeVaultWithdrawalNetwork);
        json.serialize("l1FeeVaultWithdrawalNetwork", deployCfg.l1FeeVaultWithdrawalNetwork);
        json.serialize("sequencerFeeVaultWithdrawalNetwork", deployCfg.sequencerFeeVaultWithdrawalNetwork);

        json.serialize("gasPriceOracleOverhead", deployCfg.gasPriceOracleOverhead);
        json.serialize("gasPriceOracleScalar", deployCfg.gasPriceOracleScalar);

        json.serialize("enableGovernance", deployCfg.enableGovernance);
        json.serialize("governanceTokenSymbol", deployCfg.governanceTokenSymbol);
        json.serialize("governanceTokenName", deployCfg.governanceTokenName);
        json.serialize("governanceTokenOwner", deployCfg.governanceTokenOwner);

        json.serialize("l2GenesisBlockGasLimit", _toHexWithoutZeroPadding(deployCfg.l2GenesisBlockGasLimit));
        json.serialize("l2GenesisBlockBaseFeePerGas", _toHexWithoutZeroPadding(deployCfg.l2GenesisBlockBaseFeePerGas));
        json.serialize("l2GenesisRegolithTimeOffset", _toHexWithoutZeroPadding(deployCfg.l2GenesisRegolithTimeOffset));
        json.serialize("l2GenesisCanyonTimeOffset", _toHexWithoutZeroPadding(deployCfg.l2GenesisCanyonTimeOffset));

        json.serialize("eip1559Denominator", deployCfg.eip1559Denominator);
        json.serialize("eip1559DenominatorCanyon", deployCfg.eip1559DenominatorCanyon);
        json.serialize("eip1559Elasticity", deployCfg.eip1559Elasticity);

        json.serialize("systemConfigStartBlock", deployCfg.systemConfigStartBlock);

        json.serialize("requiredProtocolVersion", deployCfg.requiredProtocolVersion);
        json.serialize("recommendedProtocolVersion", deployCfg.recommendedProtocolVersion);

        json.serialize("l1StandardBridgeProxy", deployCfg.l1StandardBridgeProxy);
        json.serialize("l1CrossDomainMessengerProxy", deployCfg.l1CrossDomainMessengerProxy);
        json.serialize("l1ERC721BridgeProxy", deployCfg.l1ERC721BridgeProxy);
        json.serialize("systemConfigProxy", deployCfg.systemConfigProxy);
        out = json.serialize("optimismPortalProxy", deployCfg.optimismPortalProxy);
        if (deployCfg.l2ZeroFeeTime > 0) {
            out = json.serialize("l2ZeroFeeTime", deployCfg.l2ZeroFeeTime);
        }
        return out;
    }

    function _addressesJson(
        string memory json,
        address proxyAdmin,
        address l2OutputOracleProxy,
        address addressManager,
        address protocolVersions
    )
        internal
        returns (string memory)
    {
        json.serialize("FinalSystemOwner", deployCfg.finalSystemOwner);
        json.serialize("P2PSequencer", deployCfg.p2pSequencerAddress);
        json.serialize("L2OutputOracleProposer", deployCfg.l2OutputOracleProposer);
        json.serialize("L2OutputOracleChallenger", deployCfg.l2OutputOracleChallenger);
        json.serialize("BatchSender", deployCfg.batchSenderAddress);
        json.serialize("ProxyAdmin", proxyAdmin);
        json.serialize("L2OutputOracleProxy", l2OutputOracleProxy);
        json.serialize("AddressManager", addressManager);
        json.serialize("ProtocolVersions", protocolVersions);
        json.serialize("SystemConfigProxy", deployCfg.systemConfigProxy);
        json.serialize("BatchInbox", deployCfg.batchInboxAddress);
        json.serialize("OptimismPortalProxy", deployCfg.optimismPortalProxy);
        json.serialize("L1CrossDomainMessengerProxy", deployCfg.l1CrossDomainMessengerProxy);
        json.serialize("L1StandardBridgeProxy", deployCfg.l1StandardBridgeProxy);
        return json.serialize("L1ERC721BridgeProxy", deployCfg.l1ERC721BridgeProxy);
    }
}

// Set the message relayer address to the OasysPortal.
contract SetMessageRelayer is Script {
    using stdJson for string;

    OasysPortal portal;

    function setUp() public {
        // get the deployed OptimismPortal contract.
        string memory addresses = vm.readFile(string.concat(Path.buildLatestOutDir(), "/addresses.json"));
        portal = OasysPortal(payable(stdJson.readAddress(addresses, "$.OptimismPortalProxy")));
    }

    function run() public {
        address oldRelayer = portal.messageRelayer();
        address newRelayer = vm.envAddress("MESSAGE_RELAYER");

        vm.startBroadcast();
        portal.setMessageRelayer(newRelayer);
        vm.stopBroadcast();

        console.log("OasysPortal: %s", address(portal));
        console.log("Old relayer: %s", oldRelayer);
        console.log("New relayer: %s", newRelayer);
    }
}
