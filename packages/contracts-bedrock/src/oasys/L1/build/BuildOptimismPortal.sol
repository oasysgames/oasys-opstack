// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IBuildOptimismPortal } from "src/oasys/L1/build/interfaces/IBuildOptimismPortal.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildOptimismPortal is IBuildOptimismPortal, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildOptimismPortal
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
            type(OptimismPortal).creationCode,
            abi.encode(
                L2OutputOracle(_l2Oracle),
                _guardian,
                false, // _paused
                SystemConfig(_systemConfig)
            )
        );
    }

    /// @inheritdoc IBuildOptimismPortal
    function initializeData(bool _paused) external pure returns (bytes memory) {
        return abi.encodeCall(OptimismPortal.initialize, (_paused));
    }
}
