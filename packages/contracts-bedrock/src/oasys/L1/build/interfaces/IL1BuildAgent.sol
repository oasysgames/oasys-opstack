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
        // the block time of l2 chain
        // Value: 2s
        uint256 l2BlockTime;
        // Used for calculate the next checkpoint block number, in Opstack case, 120 is set in testnet. 2s(default l2
        // block time) * 120 = 240s. submit l2 root every 240s. it means l2->l1 withdrawal will be available every 240s.
        // Value: 120
        uint256 l2OutputOracleSubmissionInterval;
        // The amount of time that must pass for an output proposal to be considered canonical. Once this time past,
        // anybody can delete l2 root.
        // Value: 7 days
        uint256 finalizationPeriodSeconds;
        /// ------ considering to remove the following parameters ------
        uint256 l2OutputOracleStartingBlockNumber;
        uint256 l2OutputOracleStartingTimestamp;
    }

    function chainSystemConfig(uint256 chainId) external view returns (address systemConfig);

    function chainIds(uint256 index) external view returns (uint256 chainId);

    function computeInboxAddress(uint256 chainId) external view returns (address batchInbox);

    function isUniqueChainId(uint256 chainId) external view returns (bool);

    function build(uint256 chainId, BuildConfig calldata cfg) external;
}
