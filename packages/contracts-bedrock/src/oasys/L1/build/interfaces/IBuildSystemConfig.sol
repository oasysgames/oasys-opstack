// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ResourceMetering } from "src/L1/ResourceMetering.sol";

interface IBuildSystemConfig {
    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() external pure returns (bytes memory);

    /// @notice Return data for initializer.
    /// @param _owner             Initial owner of the contract.
    /// @param _overhead          Initial overhead value.
    /// @param _scalar            Initial scalar value.
    /// @param _batcherHash       Initial batcher hash.
    /// @param _gasLimit          Initial gas limit.
    /// @param _unsafeBlockSigner Initial unsafe block signer address.
    /// @param _config            Initial resource config.
    function initializeData(
        address _owner,
        uint256 _overhead,
        uint256 _scalar,
        bytes32 _batcherHash,
        uint64 _gasLimit,
        address _unsafeBlockSigner,
        ResourceMetering.ResourceConfig memory _config
    )
        external
        pure
        returns (bytes memory);
}
