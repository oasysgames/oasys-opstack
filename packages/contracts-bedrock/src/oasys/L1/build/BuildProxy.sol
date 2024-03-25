// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { ISemver } from "src/universal/ISemver.sol";
import { IBuildProxy } from "src/oasys/L1/build/interfaces/IBuildProxy.sol";
import { Proxy } from "src/universal/Proxy.sol";

/// @notice Hold the deployment bytecode
///         Separate from build contract to avoid bytecode size limitations
contract BuildProxy is IBuildProxy, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.0.0
    string public constant version = "1.0.0";

    /// @inheritdoc IBuildProxy
    function deployProxyAdmin(address owner) external returns (ProxyAdmin proxyAdmin) {
        proxyAdmin = new ProxyAdmin({ _owner: owner });
    }

    /// @inheritdoc IBuildProxy
    function deployERC1967Proxy(address admin) external returns (Proxy proxy) {
        proxy = new Proxy({ _admin: admin });
    }
}
