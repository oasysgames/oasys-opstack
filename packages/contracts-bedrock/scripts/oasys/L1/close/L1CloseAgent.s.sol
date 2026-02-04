// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Dependencies
import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { Path } from "../build/_path.sol";

// Close contracts
import { L1CloseAgent } from "src/oasys/L1/close/L1CloseAgent.sol";
import { ClosedL1StandardBridge } from "src/oasys/L1/close/ClosedL1StandardBridge.sol";
import { ClosedL1ERC721Bridge } from "src/oasys/L1/close/ClosedL1ERC721Bridge.sol";
import { ClosedL1CrossDomainMessenger } from "src/oasys/L1/close/ClosedL1CrossDomainMessenger.sol";
import { ClosedOptimismPortal } from "src/oasys/L1/close/ClosedOptimismPortal.sol";

/// @notice Deploy L1CloseAgent (and closed implementations). Proxy admin is read from env L1_CLOSE_AGENT_PROXY_ADMIN.
/// @dev Deploy:
///   L1_CLOSE_AGENT_PROXY_ADMIN=0x<admin_address> forge script
/// scripts/oasys/L1/close/L1CloseAgent.s.sol:L1CloseAgentScript --sig runDeployL1CloseAgent --rpc-url <RPC>
/// --private-key <private_key> --broadcast
/// @dev Verify on Blockscout (from repo root). Set CHAIN_ID and BLOCKSCOUT_URL; replace <ADDR> with deployed addresses.
///
/// 1) L1CloseAgent (implementation). Constructor: (address l1buildAgent, address closedL1StandardBridge, address
/// closedL1ERC721Bridge, address closedL1CrossDomainMessenger, address closedOptimismPortal)
///    forge verify-contract <L1CloseAgent_IMPL> src/oasys/L1/close/L1CloseAgent.sol:L1CloseAgent --chain $CHAIN_ID
/// --verifier blockscout --verifier-url $BLOCKSCOUT_URL --constructor-args $(cast abi-encode
/// "constructor(address,address,address,address,address)" 0x85D92cD5d9b7942f2Ed0d02C6b5120E9D43C52aA
/// <CLOSED_STD_BRIDGE> <CLOSED_ERC721_BRIDGE> <CLOSED_CDM> <CLOSED_PORTAL>) --watch
///
/// 2) ClosedL1StandardBridge. Constructor: (address l1buildAgent)
///    forge verify-contract <CLOSED_STD_BRIDGE> src/oasys/L1/close/ClosedL1StandardBridge.sol:ClosedL1StandardBridge
/// --chain $CHAIN_ID --verifier blockscout --verifier-url $BLOCKSCOUT_URL --constructor-args $(cast abi-encode
/// "constructor(address)" 0x85D92cD5d9b7942f2Ed0d02C6b5120E9D43C52aA) --watch
///
/// 3) ClosedL1ERC721Bridge. Constructor: (address l1buildAgent)
///    forge verify-contract <CLOSED_ERC721_BRIDGE> src/oasys/L1/close/ClosedL1ERC721Bridge.sol:ClosedL1ERC721Bridge
/// --chain $CHAIN_ID --verifier blockscout --verifier-url $BLOCKSCOUT_URL --constructor-args $(cast abi-encode
/// "constructor(address)" 0x85D92cD5d9b7942f2Ed0d02C6b5120E9D43C52aA) --watch
///
/// 4) ClosedL1CrossDomainMessenger. No constructor args — omit --constructor-args.
///    forge verify-contract <CLOSED_CDM>
/// src/oasys/L1/close/ClosedL1CrossDomainMessenger.sol:ClosedL1CrossDomainMessenger --chain $CHAIN_ID --verifier
/// blockscout --verifier-url $BLOCKSCOUT_URL --watch
///
/// 5) ClosedOptimismPortal. Constructor: (address l1buildAgent)
///    forge verify-contract <CLOSED_PORTAL> src/oasys/L1/close/ClosedOptimismPortal.sol:ClosedOptimismPortal --chain
/// $CHAIN_ID --verifier blockscout --verifier-url $BLOCKSCOUT_URL --constructor-args $(cast abi-encode
/// "constructor(address)" 0x85D92cD5d9b7942f2Ed0d02C6b5120E9D43C52aA) --watch
///
/// 6) Proxy (L1CloseAgent proxy). Constructor: (address admin). Use the deployer address that was used when deploying.
///    forge verify-contract <L1_CLOSE_AGENT_PROXY> src/universal/Proxy.sol:Proxy --chain $CHAIN_ID --verifier
/// blockscout --verifier-url $BLOCKSCOUT_URL --constructor-args $(cast abi-encode "constructor(address)"
/// <DEPLOYER_ADDRESS>) --watch
contract L1CloseAgentScript is Script {
    using stdJson for string;

    address public constant L1_BUILD_AGENT = 0x85D92cD5d9b7942f2Ed0d02C6b5120E9D43C52aA;

    struct Addresses {
        address l1CloseAgent;
        address l1CloseAgentImplementation;
        address closedL1StandardBridge;
        address closedL1ERC721Bridge;
        address closedL1CrossDomainMessenger;
        address closedOptimismPortal;
    }

    Addresses _addrs;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function setUp() public virtual {
        vm.createDir({ path: Path.closeLatestOutDir(), recursive: true });
        vm.createDir({ path: Path.closeRunOutDir(), recursive: true });
    }

    function run() public pure {
        revert("Usage: L1CloseAgent.s.sol --sig runDeployL1CloseAgent");
    }

    function runDeployL1CloseAgent() public broadcast {
        console.log("L1BuildAgent: %s", L1_BUILD_AGENT);
        address proxyAdmin = vm.envAddress("L1_CLOSE_AGENT_PROXY_ADMIN");
        if (proxyAdmin == address(0)) {
            revert("L1_CLOSE_AGENT_PROXY_ADMIN is not set");
        }
        console.log("ProxyAdmin: %s", proxyAdmin);

        _deployClosedImplementations(IL1BuildAgent(L1_BUILD_AGENT));
        _deployL1CloseAgent(IL1BuildAgent(L1_BUILD_AGENT), proxyAdmin);
        _writeAddressesJson();
    }

    function _deployClosedImplementations(IL1BuildAgent _l1BuildAgent) internal {
        _addrs.closedL1StandardBridge = address(new ClosedL1StandardBridge(_l1BuildAgent));
        _addrs.closedL1ERC721Bridge = address(new ClosedL1ERC721Bridge(_l1BuildAgent));
        _addrs.closedL1CrossDomainMessenger = address(new ClosedL1CrossDomainMessenger());
        _addrs.closedOptimismPortal = address(new ClosedOptimismPortal(_l1BuildAgent));

        console.log("ClosedL1StandardBridge: %s", _addrs.closedL1StandardBridge);
        console.log("ClosedL1ERC721Bridge: %s", _addrs.closedL1ERC721Bridge);
        console.log("ClosedL1CrossDomainMessenger: %s", _addrs.closedL1CrossDomainMessenger);
        console.log("ClosedOptimismPortal: %s", _addrs.closedOptimismPortal);
    }

    function _deployL1CloseAgent(IL1BuildAgent _l1BuildAgent, address _proxyAdmin) internal {
        L1CloseAgent impl = new L1CloseAgent({
            _l1buildAgent: _l1BuildAgent,
            _closedL1StandardBridge: _addrs.closedL1StandardBridge,
            _closedL1ERC721Bridge: _addrs.closedL1ERC721Bridge,
            _closedL1CrossDomainMessenger: _addrs.closedL1CrossDomainMessenger,
            _closedOptimismPortal: _addrs.closedOptimismPortal
        });
        _addrs.l1CloseAgentImplementation = address(impl);

        // Deploy proxy with deployer (msg.sender) as initial admin, upgrade, then transfer admin to final owner
        Proxy proxy = new Proxy(msg.sender);
        proxy.upgradeTo(_addrs.l1CloseAgentImplementation);
        proxy.changeAdmin(_proxyAdmin);
        _addrs.l1CloseAgent = address(proxy);

        console.log("L1CloseAgent (proxy): %s", _addrs.l1CloseAgent);
        console.log("L1CloseAgent (implementation): %s", _addrs.l1CloseAgentImplementation);
    }

    function _writeAddressesJson() internal {
        string memory json;
        json.serialize("L1CloseAgent", _addrs.l1CloseAgent);
        json.serialize("L1CloseAgentImplementation", _addrs.l1CloseAgentImplementation);
        json.serialize("ClosedL1StandardBridge", _addrs.closedL1StandardBridge);
        json.serialize("ClosedL1ERC721Bridge", _addrs.closedL1ERC721Bridge);
        json.serialize("ClosedL1CrossDomainMessenger", _addrs.closedL1CrossDomainMessenger);
        json = json.serialize("ClosedOptimismPortal", _addrs.closedOptimismPortal);

        string memory path1 = string.concat(Path.closeLatestOutDir(), "/addresses.json");
        string memory path2 = string.concat(Path.closeRunOutDir(), "/addresses.json");
        json.write(path1);
        json.write(path2);
        console.log("Output: %s", path1);
        console.log("Output: %s", path2);
    }
}
