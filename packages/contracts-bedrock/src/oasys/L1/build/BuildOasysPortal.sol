// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { IBuildOasysPortal } from "src/oasys/L1/build/interfaces/IBuildOasysPortal.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildOasysPortal is IBuildOasysPortal, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildOasysPortal
    function deployBytecode(
        address _l2Oracle,
        address _guardian,
        address _systemConfig
    )
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            type(OasysPortal).creationCode,
            abi.encode(
                _l2Oracle,
                _guardian,
                false, // _paused
                _systemConfig
            )
        );
    }

    /// @inheritdoc IBuildOasysPortal
    function initializeData(bool _paused) external pure returns (bytes memory) {
        return abi.encodeCall(OasysPortal.initialize, (_paused));
    }
}
