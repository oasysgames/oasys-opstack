// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title L2PredeployAddresses
 */
library L2PredeployAddresses {
    /// @notice Address of the L2ERC721Bridge predeploy.
    ///         Oasys' L2 ERC721 Bridge was released
    ///         before OPStack and has a different address.
    address internal constant L2_ERC721_BRIDGE = 0x6200000000000000000000000000000000000001;
}
