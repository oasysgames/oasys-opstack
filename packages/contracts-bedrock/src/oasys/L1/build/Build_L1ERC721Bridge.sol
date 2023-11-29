// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Semver } from "../../universal/Semver.sol";
import { L1ERC721Bridge } from "../../L1/L1ERC721Bridge.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract Build_L1ERC721Bridge is Semver {
    constructor() Semver(1, 0, 0) {}

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() public pure returns (bytes memory) {
        return type(L1ERC721Bridge).creationCode;
    }
}
