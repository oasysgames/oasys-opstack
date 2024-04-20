// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";
import { LegacyL1BuildDeposit } from "src/oasys/L1/build/legacy/LegacyL1BuildDeposit.sol";

/// @notice The 2nd version of L1BuildDeposit
///         As the previous version is battle tested, remaining the same logic to mitigate the hack risk.
contract L1BuildDeposit is ISemver, LegacyL1BuildDeposit {
    /// @notice The address of the previous version of L1BuildDeposit
    IL1BuildDeposit public immutable legacyL1BuildDeposit;

    /// @notice Semantic version.
    /// @custom:semver 2.0.0
    string public constant version = "2.0.0";

    constructor(
        uint256 _requiredAmount,
        uint256 _lockedBlock,
        address _agentAddress,
        IL1BuildDeposit _legacyL1BuildDeposit
    )
        LegacyL1BuildDeposit(_requiredAmount, _lockedBlock, _agentAddress)
    {
        legacyL1BuildDeposit = _legacyL1BuildDeposit;
    }

    /**
     * @notice Marks the builder as built.
     * @param _builder Address of the Verse-Builder.
     */
    function build(address _builder) public override {
        bool isUpgradingExistingL2 = _isBuilderLegacy(_builder);

        // If not upgrading from the legacy, call the original build function.
        if (!isUpgradingExistingL2) {
            return super.build(_builder);
        }

        require(msg.sender == agentAddress, "only L1BuildAgent can call me");
        // Skip deposit check for the legacy builders.
        // require(_depositTotal[_builder] >= requiredAmount, "deposit amount shortage");
        require(getBuildBlock(_builder) == 0, "already built by builder");

        _buildBlock[_builder] = block.number;

        emit Build(_builder, block.number);
    }

    /**
     * Returns the total amount of the OAS tokens, including the legacy version.
     * @param _builder Address of the Verse-Builder.
     * @return amount Total amount of the OAS tokens.
     */
    function getDepositTotalIncludeLegacy(address _builder) public view returns (uint256) {
        return getDepositTotal(_builder) + legacyL1BuildDeposit.getDepositTotal(_builder);
    }

    /**
     * Returns the whether the address is the builder globally.
     * @param _builder Address of the Verse-Builder.
     */
    function isBuilderGlobally(address _builder) public view returns (bool) {
        return _isBuilderLegacy(_builder) || isBuilderInternally(_builder);
    }

    /**
     * Returns the whether the address is the internal builder.
     * @param _builder Address of the Verse-Builder.
     */
    function isBuilderInternally(address _builder) public view returns (bool) {
        return getBuildBlock(_builder) > 0;
    }

    function _isBuilderLegacy(address _builder) internal view returns (bool) {
        if (legacyL1BuildDeposit != IL1BuildDeposit(address(0))) {
            return legacyL1BuildDeposit.getBuildBlock(_builder) > 0;
        }
        return false;
    }
}
