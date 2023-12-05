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
                0, // _startingBlockNumber
                0, // _startingTimestamp
                _proposer,
                _challenger,
                _finalizationPeriodSeconds
            )
        );
    }

    /// @inheritdoc IBuildL2OutputOracle
    function initializeData(
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp
    )
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(L2OutputOracle.initialize, (_startingBlockNumber, _startingTimestamp));
    }
}
