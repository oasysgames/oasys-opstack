// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IL1BuildAgent {
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
        // The address of the p2p sequencer. This address is recorded in SystemConfig contract.
        // This address sign the block for p2p sync.
        // Value: depending on each verse
        address p2pSequencerAddress;
        /// The address of messager relayer.
        // Value: depending on each verse
        address messageRelayer;
        // the block time of l2 chain
        // Value: 2s
        uint256 l2BlockTime;
        // the gas limit of l2 chain
        // This value is stored on L1 SystemConfig contract, then referred by op-node to set the gas limit of l2 block.
        // Value: 30000000
        uint64 l2GasLimit;
        // Used for calculate the next checkpoint block number, in Opstack case, 120 is set in testnet. 2s(default l2
        // block time) * 120 = 240s. submit l2 root every 240s. it means l2->l1 withdrawal will be available every 240s.
        // Value: 120
        uint256 l2OutputOracleSubmissionInterval;
        // FinalizationPeriodSeconds represents the number of seconds before an output is considered
        // finalized. This impacts the amount of time that withdrawals take to finalize and is
        // generally set to 1 week.
        // Value: 7 days
        uint256 finalizationPeriodSeconds;
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
    }

    /// @notice The address list of the built L1 contract set
    struct BuiltAddressList {
        address proxyAdmin;
        address systemConfig;
        address l1StandardBridge;
        address l1ERC721Bridge;
        address l1CrossDomainMessenger;
        address oasysL2OutputOracle;
        address oasysPortal;
        address protocolVersions;
        address batchInbox;
    }

    /// @notice Event emitted when the L1 contract set is deployed
    event Deployed(uint256 indexed chainId, address finalSystemOwner, BuiltAddressList results, address[7] impls);

    function builtLists(uint256 chainId)
        external
        view
        returns (address, address, address, address, address, address, address, address, address);

    function chainIds(uint256 index) external view returns (uint256 chainId);

    function getBuilderGlobally(uint256 chainId) external view returns (address builder);

    function getBuilderInternally(uint256 _chainId) external view returns (address);

    function computeInboxAddress(uint256 chainId) external view returns (address batchInbox);

    function isUniqueChainId(uint256 chainId) external view returns (bool);

    function isUpgradingExistingL2(uint256 _chainId) external returns (bool, address);

    function pauseLegacyL1CrossDomainMessenger(uint256 _chainId, address addressManager) external;

    function unpauseLegacyL1CrossDomainMessenger(
        uint256 _chainId,
        address addressManager,
        address oldL1CrossDomainMessenger
    )
        external;

    function build(
        uint256 chainId,
        BuildConfig calldata cfg
    )
        external
        returns (BuiltAddressList memory, address[7] memory);
}
