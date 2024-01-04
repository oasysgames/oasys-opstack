// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";
import { OasysStateCommitmentChainVerifier } from "src/oasys/L1/build/legacy/OasysStateCommitmentChainVerifier.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";

/// @title OasysRollupVerifier
contract OasysRollupVerifier is OasysStateCommitmentChainVerifier {
    event L2OutputApproved(address indexed l2OutputOracle, uint256 indexed l2OutputIndex, bytes32 indexed outputRoot);

    event L2OutputRejected(address indexed l2OutputOracle, uint256 indexed l2OutputIndex, bytes32 indexed outputRoot);

    /// @notice Approve the L2 output.
    /// @param senderSignature Signature of the original message sender.
    /// @param l2OutputOracle  Address of the target L2OutputOracle.
    /// @param l2OutputIndex   Index of the target L2Output.
    /// @param l2Output        Target L2 Output.
    /// @param signatures      List of signatures.
    function approve(
        bytes calldata senderSignature,
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external
    {
        bytes32 msgHash = _getMsgHash(l2OutputOracle, l2OutputIndex, l2Output, true);
        _verifySignatures(msgHash, signatures);

        address originalSender = _recoverSigner(msgHash, senderSignature);
        OasysL2OutputOracle(l2OutputOracle).succeedVerification(originalSender, l2OutputIndex, l2Output);

        emit L2OutputApproved(l2OutputOracle, l2OutputIndex, l2Output.outputRoot);
    }

    /// @notice Reject the L2 output.
    /// @param senderSignature Signature of the original message sender.
    /// @param l2OutputOracle  Address of the target L2OutputOracle.
    /// @param l2OutputIndex   Index of the target L2Output.
    /// @param l2Output        Target L2 Output.
    /// @param signatures      List of signatures.
    function reject(
        bytes calldata senderSignature,
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external
    {
        bytes32 msgHash = _getMsgHash(l2OutputOracle, l2OutputIndex, l2Output, false);
        _verifySignatures(msgHash, signatures);

        address originalSender = _recoverSigner(msgHash, senderSignature);
        OasysL2OutputOracle(l2OutputOracle).failVerification(originalSender, l2OutputIndex, l2Output);

        emit L2OutputRejected(l2OutputOracle, l2OutputIndex, l2Output.outputRoot);
    }

    /// @notice Create data to be signed and return its message hash.
    /// @param l2OutputOracle Address of the target L2OutputOracle.
    /// @param l2OutputIndex  Index of the target L2Output.
    /// @param l2Output       Target L2 Output.
    /// @param approved       Approve or Reject.
    function _getMsgHash(
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bool approved
    )
        internal
        view
        returns (bytes32)
    {
        bytes memory signData = abi.encodePacked(
            block.chainid,
            l2OutputOracle,
            l2OutputIndex,
            // Prevent reuse of signature by including L1 timestamp.
            abi.encodePacked(l2Output.outputRoot, l2Output.timestamp, l2Output.l2BlockNumber),
            approved
        );
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(signData)));
    }
}
