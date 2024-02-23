// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* External Imports */
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/* Interface Imports */
import { IEnvironment } from "./IEnvironment.sol";
import { IStakeManager } from "./IStakeManager.sol";
import { IOasysStateCommitmentChain } from "./IOasysStateCommitmentChain.sol";

/* Library Imports */
import { Lib_OVMCodec } from "./Lib_OVMCodec.sol";
import { PredeployAddresses } from "./PredeployAddresses.sol";

/**
 * @title OasysStateCommitmentChainVerifier
 * @dev The Oasys State Commitment Chain Verifier is a contract
 * that verifies based on the verifier's total stake.
 */
contract OasysStateCommitmentChainVerifier {
    /**
     *
     * Events *
     *
     */

    event StateBatchApproved(address indexed stateCommitmentChain, uint256 indexed batchIndex, bytes32 batchRoot);
    event StateBatchRejected(address indexed stateCommitmentChain, uint256 indexed batchIndex, bytes32 batchRoot);

    /**
     *
     * Errors *
     *
     */

    error InvalidSignature(bytes signature, string reason);
    error InvalidAddressSort(address signer);
    error StakeAmountShortage(uint256 required, uint256 verified);

    /**
     *
     * Public Functions *
     *
     */

    /**
     * Approve the state batch.
     * @param stateCommitmentChain Address of the target IOasysStateCommitmentChain.
     * @param batchHeader          Target batch header.
     * @param signatures           List of signatures.
     */
    function approve(
        address stateCommitmentChain,
        Lib_OVMCodec.ChainBatchHeader memory batchHeader,
        bytes[] memory signatures
    )
        public
    {
        _verifySignatures(_getMsgHash(stateCommitmentChain, batchHeader, true), signatures);

        IOasysStateCommitmentChain(stateCommitmentChain).succeedVerification(batchHeader);

        emit StateBatchApproved(stateCommitmentChain, batchHeader.batchIndex, batchHeader.batchRoot);
    }

    /**
     * Reject the state batch.
     * @param stateCommitmentChain Address of the target IOasysStateCommitmentChain.
     * @param batchHeader          Target batch header.
     * @param signatures           List of signatures.
     */
    function reject(
        address stateCommitmentChain,
        Lib_OVMCodec.ChainBatchHeader memory batchHeader,
        bytes[] memory signatures
    )
        public
    {
        _verifySignatures(_getMsgHash(stateCommitmentChain, batchHeader, false), signatures);

        IOasysStateCommitmentChain(stateCommitmentChain).failVerification(batchHeader);

        emit StateBatchRejected(stateCommitmentChain, batchHeader.batchIndex, batchHeader.batchRoot);
    }

    /**
     *
     * Internal Functions *
     *
     */

    /**
     * Create data to be signed and return its message hash.
     * @param stateCommitmentChain Address of the target IOasysStateCommitmentChain.
     * @param batchHeader          Target state.
     * @param approved             Approve or Reject.
     */
    function _getMsgHash(
        address stateCommitmentChain,
        Lib_OVMCodec.ChainBatchHeader memory batchHeader,
        bool approved
    )
        internal
        view
        returns (bytes32)
    {
        bytes memory signData = abi.encodePacked(
            block.chainid, stateCommitmentChain, batchHeader.batchIndex, batchHeader.batchRoot, approved
        );
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(signData)));
    }

    /**
     * Verify signatures.
     * @param msgHash    Message hash of data to be signed.
     * @param signatures List of signatures.
     */
    function _verifySignatures(bytes32 msgHash, bytes[] memory signatures) internal view {
        _verifyTotalStakeOverHalf(_recoverSigners(msgHash, signatures));
    }

    /**
     * Verify total stake is over half.
     * @param verifiers List of verifiers.
     */
    function _verifyTotalStakeOverHalf(address[] memory verifiers) internal view {
        IEnvironment environment = IEnvironment(PredeployAddresses.ENVIRONMENT);
        IStakeManager stakeManager = IStakeManager(PredeployAddresses.STAKE_MANAGER);

        uint256 epoch = environment.epoch();
        uint256 signersCount = verifiers.length;
        uint256 verified = 0;
        for (uint256 i = 0; i < signersCount; i++) {
            verified += stakeManager.getOperatorStakes(verifiers[i], epoch);
        }

        uint256 required = (stakeManager.getTotalStake(epoch) * 51) / 100;
        if (verified < required) {
            revert StakeAmountShortage(required, verified);
        }
    }

    /**
     * Returns a list of addresses that signed the hashed message.
     * @param msgHash    Message hash of data to be signed.
     * @param signatures Signature list to be recoverd.
     */
    function _recoverSigners(
        bytes32 msgHash,
        bytes[] memory signatures
    )
        internal
        pure
        returns (address[] memory signers)
    {
        signers = new address[](signatures.length);

        address lastSigner = address(0);
        for (uint256 i = 0; i < signatures.length; i++) {
            address signer = _recoverSigner(msgHash, signatures[i]);
            if (signer <= lastSigner) {
                revert InvalidAddressSort(signer);
            }

            signers[i] = signer;
            lastSigner = signer;
        }
    }

    /**
     * Returns a list of addresses that signed the hashed message.
     * @param msgHash   Message hash of data to be signed.
     * @param signature Signature to be recoverd.
     */
    function _recoverSigner(bytes32 msgHash, bytes memory signature) internal pure returns (address) {
        (address signer, ECDSA.RecoverError err) = ECDSA.tryRecover(msgHash, signature);

        if (err == ECDSA.RecoverError.NoError) {
            return signer;
        } else if (err == ECDSA.RecoverError.InvalidSignature) {
            revert InvalidSignature(signature, "ECDSA: invalid signature");
        } else if (err == ECDSA.RecoverError.InvalidSignatureLength) {
            revert InvalidSignature(signature, "ECDSA: invalid signature length");
        } else if (err == ECDSA.RecoverError.InvalidSignatureS) {
            revert InvalidSignature(signature, "ECDSA: invalid signature 's' value");
        } else if (err == ECDSA.RecoverError.InvalidSignatureV) {
            revert InvalidSignature(signature, "ECDSA: invalid signature 'v' value");
        }
        revert InvalidSignature(signature, "ECDSA: invalid signature");
    }
}
