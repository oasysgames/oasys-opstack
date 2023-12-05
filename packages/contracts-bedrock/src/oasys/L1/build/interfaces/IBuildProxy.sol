// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { AddressManager } from "src/legacy/AddressManager.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { L1ChugSplashProxy } from "src/legacy/L1ChugSplashProxy.sol";
import { ResolvedDelegateProxy } from "src/legacy/ResolvedDelegateProxy.sol";

interface IBuildProxy {
    /// @notice Deploy the AddressManager.
    /// @param owner Initial owner of the contract.
    function deployAddressManager(address owner) external returns (AddressManager addressManager);

    /// @notice Deploy the proxyAdmin.
    /// @param owner Initial owner of the contract.
    function deployProxyAdmin(address owner) external returns (ProxyAdmin proxyAdmin);

    /// @notice Deploy the Proxy.
    /// @param admin Initial admin of the contract.
    function deployERC1967Proxy(address admin) external returns (Proxy proxy);

    /// @notice Deploy the L1ChugSplashProxy.
    /// @param owner Initial owner of the contract.
    function deployChugProxy(address owner) external returns (L1ChugSplashProxy proxy);

    /// @notice Deploy the ResolvedDelegateProxy.
    /// @param addressManager     Address of the AddressManager.
    /// @param implementationName implementationName of the contract to proxy to.
    function deployResolvedProxy(
        address addressManager,
        string memory implementationName
    )
        external
        returns (ResolvedDelegateProxy proxy);
}
