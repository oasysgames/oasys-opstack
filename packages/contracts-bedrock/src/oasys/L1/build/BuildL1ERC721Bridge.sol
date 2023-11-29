// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { IBuildCommon } from "src/oasys/L1/build/interfaces/IBuildCommon.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL1ERC721Bridge is IBuildCommon, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    constructor() ISemver(1, 0, 0) { }

    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() public pure returns (bytes memory) {
        return type(L1ERC721Bridge).creationCode;
    }
}
