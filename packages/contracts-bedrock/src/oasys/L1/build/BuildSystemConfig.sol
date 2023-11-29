// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { IBuildSystemConfig } from "src/oasys/L1/build/interfaces/IBuildSystemConfig.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildSystemConfig is IBuildSystemConfig, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildSystemConfig
    function deployBytecode() public pure returns (bytes memory) {
        return type(SystemConfig).creationCode;
    }

    /// @inheritdoc IBuildSystemConfig
    function initializeData(
        address _owner,
        uint256 _overhead,
        uint256 _scalar,
        bytes32 _batcherHash,
        uint64 _gasLimit,
        address _unsafeBlockSigner,
        ResourceMetering.ResourceConfig memory _config
    )
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(
            SystemConfig.initialize, (_owner, _overhead, _scalar, _batcherHash, _gasLimit, _unsafeBlockSigner, _config)
        );
    }
}
