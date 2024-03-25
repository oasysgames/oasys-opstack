// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";

interface IBuildProxy {
    /// @notice Deploy the proxyAdmin.
    /// @param owner Initial owner of the contract.
    function deployProxyAdmin(address owner) external returns (ProxyAdmin proxyAdmin);

    /// @notice Deploy the Proxy.
    /// @param admin Initial admin of the contract.
    function deployERC1967Proxy(address admin) external returns (Proxy proxy);
}
