// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";
import { IBuildOasysL1ERC721Bridge } from "src/oasys/L1/build/interfaces/IBuildOasysL1ERC721Bridge.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildOasysL1ERC721Bridge is IBuildOasysL1ERC721Bridge, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildOasysL1ERC721Bridge
    function deployBytecode(address _messenger, address _otherBridge) public pure returns (bytes memory) {
        return abi.encodePacked(type(OasysL1ERC721Bridge).creationCode, abi.encode(_messenger, _otherBridge));
    }
}
