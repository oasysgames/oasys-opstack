// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ProtocolVersion } from "src/L1/ProtocolVersions.sol";

interface IBuildProtocolVersions {
    /// @notice The create2 salt used for deployment of the contract implementations.
    function deployBytecode() external pure returns (bytes memory);

    /// @notice Return data for initializer.
    /// @param _owner             Initial owner of the contract.
    /// @param _required          Required protocol version to operate on this chain.
    /// @param _recommended       Recommended protocol version to operate on thi chain.
    function initializeData(
        address _owner,
        ProtocolVersion _required,
        ProtocolVersion _recommended
    )
        external
        pure
        returns (bytes memory);
}
