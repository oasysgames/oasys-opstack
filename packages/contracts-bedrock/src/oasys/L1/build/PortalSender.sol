// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { OptimismPortal } from "src/L1/OptimismPortal.sol";

/**
 * @title PortalSender
 * @notice The PortalSender is a simple intermediate contract that will transfer the balance of the
 *         L1StandardBridge to the OptimismPortal during the Bedrock migration.
 */
// Copied from https://github.com/oasysgames/oasys-opstack/blob/cd7c58349542f9f1ce9fd42c9054aeed1325e02c/packages/contracts-bedrock/contracts/deployment/PortalSender.sol
contract PortalSender {
    /**
     * @notice Address of the OptimismPortal contract.
     */
    OptimismPortal public immutable PORTAL;

    /**
     * @param _portal Address of the OptimismPortal contract.
     */
    constructor(OptimismPortal _portal) {
        PORTAL = _portal;
    }

    /**
     * @notice Sends balance of this contract to the OptimismPortal.
     */
    function donate() public {
        PORTAL.donateETH{ value: address(this).balance }();
    }
}