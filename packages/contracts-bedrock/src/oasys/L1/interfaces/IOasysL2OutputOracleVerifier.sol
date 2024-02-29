// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";

/// @title IOasysL2OutputOracleVerifier
interface IOasysL2OutputOracleVerifier {
    event L2OutputApproved(address indexed l2OutputOracle, uint256 indexed l2OutputIndex, bytes32 indexed outputRoot);
    event L2OutputRejected(address indexed l2OutputOracle, uint256 indexed l2OutputIndex, bytes32 indexed outputRoot);

    /// @notice Approve the L2 output.
    /// @param l2OutputOracle Address of the target L2OutputOracle.
    /// @param l2OutputIndex  Index of the target L2Output.
    /// @param l2Output       Target L2 Output.
    /// @param signatures     List of signatures.
    function approve(
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external;

    /// @notice Reject the L2 output.
    /// @param l2OutputOracle Address of the target L2OutputOracle.
    /// @param l2OutputIndex  Index of the target L2Output.
    /// @param l2Output       Target L2 Output.
    /// @param signatures     List of signatures.
    function reject(
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external;
}
