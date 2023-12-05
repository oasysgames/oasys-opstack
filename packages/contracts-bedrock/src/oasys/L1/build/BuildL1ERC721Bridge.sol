// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { IBuildL1ERC721Bridge } from "src/oasys/L1/build/interfaces/IBuildL1ERC721Bridge.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL1ERC721Bridge is IBuildL1ERC721Bridge, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildL1ERC721Bridge
    function deployBytecode(address _messenger, address _otherBridge) public pure returns (bytes memory) {
        return abi.encodePacked(type(L1ERC721Bridge).creationCode, abi.encode(_messenger, _otherBridge));
    }
}
