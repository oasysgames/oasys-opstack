// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { IBuildL1StandardBridge } from "src/oasys/L1/build/interfaces/IBuildL1StandardBridge.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL1StandardBridge is IBuildL1StandardBridge, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildL1StandardBridge
    function deployBytecode(
        address _owner,
        uint256 _overhead,
        uint256 _scalar,
        bytes32 _batcherHash,
        uint64 _gasLimit,
        address _unsafeBlockSigner,
        ResourceMetering.ResourceConfig memory _config
    )
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            type(L1StandardBridge).creationCode,
            abi.encode(_owner, _overhead, _scalar, _batcherHash, _gasLimit, _unsafeBlockSigner, _config)
        );
    }
}
