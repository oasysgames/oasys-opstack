// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { IOasysL2OutputOracle } from "src/oasys/L1/interfaces/IOasysL2OutputOracle.sol";

/// @custom:proxied
/// @title OasysPortal
/// @notice The OasysPortal is TODO
contract OasysPortal is OptimismPortal {
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
