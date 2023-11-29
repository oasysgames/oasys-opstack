// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBuildCommon {
    function deployBytecode() external pure returns (bytes memory);
}
