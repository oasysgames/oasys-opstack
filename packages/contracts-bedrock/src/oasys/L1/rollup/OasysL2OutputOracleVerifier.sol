// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";
import { OasysStateCommitmentChainVerifier } from "src/oasys/L1/build/legacy/OasysStateCommitmentChainVerifier.sol";
import { ISemver } from "src/universal/ISemver.sol";
import { IOasysL2OutputOracleVerifier } from "src/oasys/L1/interfaces/IOasysL2OutputOracleVerifier.sol";
import { IOasysL2OutputOracle } from "src/oasys/L1/interfaces/IOasysL2OutputOracle.sol";

/// @title OasysL2OutputOracleVerifier
contract OasysL2OutputOracleVerifier is OasysStateCommitmentChainVerifier, IOasysL2OutputOracleVerifier, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IOasysL2OutputOracleVerifier
    function approve(
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external
    {
        _verifySignatures(_getMsgHash(l2OutputOracle, l2OutputIndex, l2Output, true), signatures);

        IOasysL2OutputOracle(l2OutputOracle).succeedVerification(l2OutputIndex, l2Output);

        emit L2OutputApproved(l2OutputOracle, l2OutputIndex, l2Output.outputRoot);
    }

    /// @inheritdoc IOasysL2OutputOracleVerifier
    function reject(
        address l2OutputOracle,
        uint256 l2OutputIndex,
        Types.OutputProposal calldata l2Output,
        bytes[] calldata signatures
    )
        external
    {
        _verifySignatures(_getMsgHash(l2OutputOracle, l2OutputIndex, l2Output, false), signatures);

        IOasysL2OutputOracle(l2OutputOracle).failVerification(l2OutputIndex, l2Output);

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
            keccak256(
                abi.encodePacked(
                    l2Output.outputRoot,
                    // Prevent reuse of signature by including L1 timestamp.
                    l2Output.timestamp,
                    l2Output.l2BlockNumber
                )
            ),
            approved
        );
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(signData)));
    }
}
