// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";

/// @title IOasysL2OutputOracle
interface IOasysL2OutputOracle {
    /// @notice Emitted when an output is verified.
    /// @param l2OutputIndex The index of the output in the l2Outputs array.
    /// @param outputRoot    The output root.
    /// @param l2BlockNumber The L2 block number of the output root.
    event OutputVerified(uint256 indexed l2OutputIndex, bytes32 indexed outputRoot, uint128 indexed l2BlockNumber);

    /// @notice Emitted when output is rejected.
    /// @param l2OutputIndex The index of the output in the l2Outputs array.
    /// @param outputRoot    The output root.
    /// @param l2BlockNumber The L2 block number of the output root.
    event OutputFailed(uint256 indexed l2OutputIndex, bytes32 indexed outputRoot, uint128 indexed l2BlockNumber);

    /// @notice Next L2Output index to verify.
    function nextVerifyIndex() external view returns (uint256);

    /// @notice Method called by the OasysRollupVerifier after a verification successful.
    /// @param l2OutputIndex Index of the target output.
    /// @param l2Output      Target L2 Output.
    function succeedVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external;

    /// @notice Method called by the OasysRollupVerifier after a verification failure.
    /// @param l2OutputIndex Index of the target output.
    /// @param l2Output      Target L2 Output.
    function failVerification(uint256 l2OutputIndex, Types.OutputProposal calldata l2Output) external;

    /// @notice Return the verified block timestamp in L1.
    function verifiedL1Timestamp() external view returns (uint128);

    /// @notice Returns whether the specified L2Output has been finalized.
    /// @param l2OutputIndex Index of the target output.
    function isOutputFinalized(uint256 l2OutputIndex) external view returns (bool);
}
