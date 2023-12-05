// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Lib_OVMCodec
 */
library Lib_OVMCodec {
    struct ChainBatchHeader {
        uint256 batchIndex;
        bytes32 batchRoot;
        uint256 batchSize;
        uint256 prevTotalElements;
        bytes extraData;
    }
}
