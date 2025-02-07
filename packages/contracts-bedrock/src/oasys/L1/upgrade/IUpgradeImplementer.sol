// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/// @title IUpgradeImplementer
/// @notice L1 Upgrade implementer interface
interface IUpgradeImplementer {
    /// @notice Returns the implementer index in the upgrade process
    function implementerIndex() external view returns (uint256);

    /// @notice Returns the upgrade name (e.g., Bedrock)
    function upgradeName() external view returns (string memory);

    /// @notice Returns the total number of steps in the upgrade process
    function totalSteps() external view returns (uint256);

    /// @notice Executes the specified upgrade step
    /// @dev Can only be called by the UpgradeManager contract
    /// @param _chainId The chain ID where the upgrade is occurring
    /// @param _step The step number to execute
    /// @return _completed True if all upgrade steps are completed
    function executeUpgradeStep(uint256 _chainId, uint8 _step) external returns (bool _completed);
}
