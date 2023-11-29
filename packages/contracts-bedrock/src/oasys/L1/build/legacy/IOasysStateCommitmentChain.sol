// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import { Lib_OVMCodec } from "./Lib_OVMCodec.sol";

/**
 * @title IOasysStateCommitmentChain
 */
interface IOasysStateCommitmentChain {
    function succeedVerification(Lib_OVMCodec.ChainBatchHeader memory _batchHeader) external;

    function failVerification(Lib_OVMCodec.ChainBatchHeader memory _batchHeader) external;
}
