// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";
import { Constants } from "src/libraries/Constants.sol";
import { SafeCall } from "src/libraries/SafeCall.sol";
import { Hashing } from "src/libraries/Hashing.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IOasysL2OutputOracle } from "src/oasys/L1/interfaces/IOasysL2OutputOracle.sol";

/// @custom:proxied
/// @title OasysPortal
/// @notice The OasysPortal is TODO
contract OasysPortal is OptimismPortal {
    /// @notice Message relayer to allowed immediate withdraw.
    address public messageRelayer;

    /// @notice Emitted when a new message relayer is set.
    /// @param relayer The address of the new message relayer.
    event MessageRelayerSet(address indexed relayer);

    constructor(
        L2OutputOracle _l2Oracle,
        address _guardian,
        bool _paused,
        SystemConfig _systemConfig
    )
        OptimismPortal(_l2Oracle, _guardian, _paused, _systemConfig)
    { }

    /// @inheritdoc OptimismPortal
    function initialize(bool _paused) public override {
        super.initialize(_paused);
    }

    /// @notice Set a new message relayer address.
    ///         If the zero address is set, no immediate relay of withdrawal messages.
    function setMessageRelayer(address newRelayer) external {
        require(msg.sender == GUARDIAN, "OasysPortal: only guardian can set a new message relayer");
        require(newRelayer != messageRelayer, "OasysPortal: already set");

        messageRelayer = newRelayer;
        emit MessageRelayerSet(newRelayer);
    }

    /// @notice Finalizes a withdrawal transaction.
    function finalizeWithdrawalTransaction(Types.WithdrawalTransaction calldata _tx) external override whenNotPaused {
        // Make sure that the l2Sender has not yet been set. The l2Sender is set to a value other
        // than the default value when a withdrawal transaction is being finalized. This check is
        // a defacto reentrancy guard.
        require(l2Sender == Constants.DEFAULT_L2_SENDER, "OasysPortal: can only trigger one withdrawal per transaction");

        // Grab the proven withdrawal from the `provenWithdrawals` map.
        bytes32 withdrawalHash = Hashing.hashWithdrawal(_tx);
        ProvenWithdrawal memory provenWithdrawal = provenWithdrawals[withdrawalHash];

        // A withdrawal can only be finalized if it has been proven. We know that a withdrawal has
        // been proven at least once when its timestamp is non-zero. Unproven withdrawals will have
        // a timestamp of zero.
        require(provenWithdrawal.timestamp != 0, "OasysPortal: withdrawal has not been proven yet");

        // As a sanity check, we make sure that the proven withdrawal's timestamp is greater than
        // starting timestamp inside the L2OutputOracle. Not strictly necessary but extra layer of
        // safety against weird bugs in the proving step.
        require(
            provenWithdrawal.timestamp >= L2_ORACLE.startingTimestamp(),
            "OasysPortal: withdrawal timestamp less than L2 Oracle starting timestamp"
        );

        // If the caller is not an message relayer,
        // a proven withdrawal must wait at least the finalization period before it can be
        // finalized. This waiting period can elapse in parallel with the waiting period for the
        // output the withdrawal was proven against. In effect, this means that the minimum
        // withdrawal time is proposal submission time + finalization period.
        if (msg.sender != messageRelayer) {
            require(
                super._isFinalizationPeriodElapsed(provenWithdrawal.timestamp),
                "OasysPortal: proven withdrawal finalization period has not elapsed"
            );
        }

        // Grab the OutputProposal from the L2OutputOracle, will revert if the output that
        // corresponds to the given index has not been proposed yet.
        Types.OutputProposal memory proposal = L2_ORACLE.getL2Output(provenWithdrawal.l2OutputIndex);

        // Check that the output root that was used to prove the withdrawal is the same as the
        // current output root for the given output index. An output root may change if it is
        // deleted by the challenger address and then re-proposed.
        require(
            proposal.outputRoot == provenWithdrawal.outputRoot,
            "OasysPortal: output root proven is not the same as current output root"
        );

        // Check that the output proposal has also been finalized.
        require(
            _isFinalizationPeriodElapsed(proposal.timestamp),
            "OasysPortal: output proposal finalization period has not elapsed"
        );

        // Check that this withdrawal has not already been finalized, this is replay protection.
        require(finalizedWithdrawals[withdrawalHash] == false, "OasysPortal: withdrawal has already been finalized");

        // Mark the withdrawal as finalized so it can't be replayed.
        finalizedWithdrawals[withdrawalHash] = true;

        // Set the l2Sender so contracts know who triggered this withdrawal on L2.
        l2Sender = _tx.sender;

        // Trigger the call to the target contract. We use a custom low level method
        // SafeCall.callWithMinGas to ensure two key properties
        //   1. Target contracts cannot force this call to run out of gas by returning a very large
        //      amount of data (and this is OK because we don't care about the returndata here).
        //   2. The amount of gas provided to the execution context of the target is at least the
        //      gas limit specified by the user. If there is not enough gas in the current context
        //      to accomplish this, `callWithMinGas` will revert.
        bool success = SafeCall.callWithMinGas(_tx.target, _tx.gasLimit, _tx.value, _tx.data);

        // Reset the l2Sender back to the default value.
        l2Sender = Constants.DEFAULT_L2_SENDER;

        // All withdrawals are immediately finalized. Replayability can
        // be achieved through contracts built on top of this contract
        emit WithdrawalFinalized(withdrawalHash, success);

        // Reverting here is useful for determining the exact gas cost to successfully execute the
        // sub call to the target contract if the minimum gas limit specified by the user would not
        // be sufficient to execute the sub call.
        if (success == false && tx.origin == Constants.ESTIMATION_ADDRESS) {
            revert("OasysPortal: withdrawal failed");
        }
    }

    /// @notice Determines whether the finalization period has elapsed with respect to
    ///         the provided block timestamp.
    /// @param _timestamp Timestamp to check.
    /// @return Whether or not the finalization period has elapsed.
    function _isFinalizationPeriodElapsed(uint256 _timestamp) internal view override returns (bool) {
        uint256 verified = IOasysL2OutputOracle(address(L2_ORACLE)).verifiedL1Timestamp();
        if (verified > 0 && verified > _timestamp) {
            return true;
        }
        return super._isFinalizationPeriodElapsed(_timestamp);
    }
}
