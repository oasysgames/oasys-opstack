// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { ProtocolVersion, ProtocolVersions } from "src/L1/ProtocolVersions.sol";
import { IBuildProtocolVersions } from "src/oasys/L1/build/interfaces/IBuildProtocolVersions.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildProtocolVersions is IBuildProtocolVersions, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildProtocolVersions
    function deployBytecode() public pure returns (bytes memory) {
        return abi.encodePacked(type(ProtocolVersions).creationCode);
    }

    /// @inheritdoc IBuildProtocolVersions
    function initializeData(
        address _owner,
        ProtocolVersion _required,
        ProtocolVersion _recommended
    )
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(ProtocolVersions.initialize, (_owner, _required, _recommended));
    }
}
