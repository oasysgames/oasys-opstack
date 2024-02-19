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

    /// @notice Batch finalizes withdrawal transactions.
    ///         This method is necessary because it is not possible to check
    ///         whether msg.sender is a message relayer via the Multicall contract.
    function finalizeWithdrawalTransactions(Types.WithdrawalTransaction[] calldata _txs) external {
        uint256 length = _txs.length;
        for (uint256 i = 0; i < length; i++) {
            finalizeWithdrawalTransaction(_txs[i]);
        }
    }

    /// @notice Determines whether the finalization period has elapsed with respect to
    ///         the provided block timestamp.
    ///         If the caller is an authorized message relayer and the timestamp
    ///         is immediately verified, no need to wait for the finalization period.
    /// @param _timestamp Timestamp to check.
    /// @return Whether or not the finalization period has elapsed.
    function _isFinalizationPeriodElapsed(uint256 _timestamp) internal view override returns (bool) {
        if (messageRelayer != address(0) && msg.sender == messageRelayer) {
            // Note: If called with `eth_call`, this code block
            //       will not pass because `msg.sender` is fixed at zero address.
            uint256 verified = IOasysL2OutputOracle(address(L2_ORACLE)).verifiedL1Timestamp();
            if (verified > _timestamp) {
                return true;
            }
        }
        return super._isFinalizationPeriodElapsed(_timestamp);
    }
}
