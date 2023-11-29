// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { OptimismPortal } from "src/L1/OptimismPortal.sol";

interface IBuildL1CrossDomainMessenger {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _portal Address of the OptimismPortal contract on this network.
    function deployBytecode(OptimismPortal _portal) external pure returns (bytes memory);
}
