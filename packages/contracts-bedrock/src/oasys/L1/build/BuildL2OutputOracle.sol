// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { IBuildL2OutputOracle } from "src/oasys/L1/build/interfaces/IBuildL2OutputOracle.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildL2OutputOracle is IBuildL2OutputOracle, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildL2OutputOracle
    function deployBytecode(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp,
        address _proposer,
        address _challenger,
        uint256 _finalizationPeriodSeconds
    )
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            abi.encodePacked(type(L2OutputOracle).creationCode),
            abi.encode(
                _submissionInterval,
                _l2BlockTime,
                _startingBlockNumber,
                _startingTimestamp,
                _proposer,
                _challenger,
                _finalizationPeriodSeconds
            )
        );
    }
}
