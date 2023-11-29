// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";

interface IBuildOptimismPortal {
    /// @notice The create2 salt used for deployment of the contract implementations.
    /// @param _l2Oracle Address of the L2OutputOracle contract.
    /// @param _guardian Address that can pause withdrawals.
    /// @param _paused Sets the contract's pausability state.
    /// @param _systemConfig Address of the SystemConfig contract.
    function deployBytecode(
        L2OutputOracle _l2Oracle,
        address _guardian,
        bool _paused,
        SystemConfig _systemConfig
    )
        external
        pure
        returns (bytes memory);
}
