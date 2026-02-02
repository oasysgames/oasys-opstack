// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";

/// @title ClosedL1CrossDomainMessenger
/// @notice L1 cross-domain messenger in a "closed" state.
contract ClosedL1CrossDomainMessenger is L1CrossDomainMessenger {
    /// @notice Reverts on every call. The messenger is closed and does not accept new messages.
    function _sendMessage(
        address, /*_to*/
        uint64, /*_gasLimit*/
        uint256, /*_value*/
        bytes memory /*_data*/
    )
        internal
        virtual
        override
    {
        revert("messenger is closed");
    }
}
