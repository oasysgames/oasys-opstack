// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { IBuildOasysL2OutputOracle } from "src/oasys/L1/build/interfaces/IBuildOasysL2OutputOracle.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildOasysL2OutputOracle is IBuildOasysL2OutputOracle, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildOasysL2OutputOracle
    function deployBytecode(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        address _proposer,
        address _challenger,
        uint256 _finalizationPeriodSeconds,
        address _verifier
    )
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            abi.encodePacked(type(OasysL2OutputOracle).creationCode),
            abi.encode(
                _submissionInterval,
                _l2BlockTime,
                0, // _startingBlockNumber
                0, // _startingTimestamp
                _proposer,
                _challenger,
                _finalizationPeriodSeconds,
                _verifier
            )
        );
    }

    /// @inheritdoc IBuildOasysL2OutputOracle
    function initializeData(
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp
    )
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(OasysL2OutputOracle.initialize, (_startingBlockNumber, _startingTimestamp));
    }
}
