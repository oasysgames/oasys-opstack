// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Dependencies
import { Script } from "forge-std/Script.sol";
import { Vm } from "forge-std/Vm.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { Path } from "../build/_path.sol";

// Upgrade contracts
import { IUpgradeManager } from "src/oasys/L1/upgrade/IUpgradeManager.sol";
import { IUpgradeImplementer } from "src/oasys/L1/upgrade/IUpgradeImplementer.sol";
import { UpgradeManager } from "src/oasys/L1/upgrade/UpgradeManager.sol";
import { BedrockToGranite } from "src/oasys/L1/upgrade/BedrockToGranite.sol";

// Optimism contracts
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OasysPortal } from "src/oasys/L1/messaging/OasysPortal.sol";
import { OasysL2OutputOracle } from "src/oasys/L1/rollup/OasysL2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { OasysL1ERC721Bridge } from "src/oasys/L1/messaging/OasysL1ERC721Bridge.sol";

contract UpgradeManagerScript is Script {
    using stdJson for string;

    struct Addresses {
        address upgradeManagerProxy;
        address bedrockToGranite;
        address superchainConfig;
        address optimismPortal;
        address l2OutputOracle;
        address systemConfig;
        address l1CrossDomainMessenger;
        address l1StandardBridge;
        address l1ERC721Bridge;
        // Address of the newly deployed SuperchainConfigProxy
        address superchainConfigProxy;
    }

    Addresses _addrs;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function setUp() public virtual {
        vm.createDir({ path: Path.upgradeLatestOutDir(), recursive: true });
        vm.createDir({ path: Path.upgradeRunOutDir(), recursive: true });
    }

    function run() public pure {
        revert("Usage: UpgradeManagerScript.s.sol --sig {runDeployUpgradeManager,runUpgradeBedrockToGranite}");
    }

    function runDeployUpgradeManager() public broadcast {
        address owner = msg.sender;
        address l1BuildAgent = address(_getL1BuildAgent());
        console.log("Owner: %s", owner);
        console.log("L1BuildAgent: %s", l1BuildAgent);

        _deploy_UpgradeManager(owner, l1BuildAgent);

        _deploy_BedrockToGraniteImplementer();

        UpgradeManager(_addrs.upgradeManagerProxy).addNextImplementer({
            _implementer: IUpgradeImplementer(_addrs.bedrockToGranite)
        });

        _writeAddressesJson();
    }

    function runUpgradeBedrockToGranite() public broadcast {
        uint256 l2ChainId = vm.envUint("L2_CHAIN_ID");
        (address proxyAdmin,,,,,,,,) = _getL1BuildAgent().builtLists(l2ChainId);
        console.log("L2ChainID: %s", l2ChainId);
        console.log("ProxyAdmin: %s", proxyAdmin);

        _loadAddressesJson();
        UpgradeManager upgradeManager = UpgradeManager(_addrs.upgradeManagerProxy);

        // Transfer ProxyAdmin ownership to the UpgradeManager
        upgradeManager.registerProxyAdminOwnerBeforeTransfer(l2ChainId);
        ProxyAdmin(proxyAdmin).transferOwnership(address(_addrs.upgradeManagerProxy));

        // Execute upgrade
        vm.recordLogs();
        upgradeManager.upgradeContracts(l2ChainId);

        // Find address of newly deployed SuperchainConfigProxy
        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            bytes32 eventSig = logs[i].topics[0];
            if (eventSig == keccak256("ProxyDeployed(uint256,string,address)")) {
                _addrs.superchainConfigProxy = abi.decode(logs[i].data, (address));
            }
        }
        require(_addrs.superchainConfigProxy != address(0), "Could not find SuperchainConfigProxy address");

        console.log("SuperchainConfigProxy: %s", _addrs.superchainConfigProxy);

        _writeAddressesJson();
    }

    function _getL1BuildAgent() internal view returns (IL1BuildAgent) {
        string memory json = vm.readFile(Path.deployLatestOutPath());
        return IL1BuildAgent(stdJson.readAddress(json, "$.L1BuildAgent"));
    }

    function _deploy_UpgradeManager(address _owner, address _l1BuildAgent) internal {
        UpgradeManager impl = new UpgradeManager();
        Proxy proxy = new Proxy({ _admin: _owner });
        proxy.upgradeToAndCall({
            _implementation: address(impl),
            _data: abi.encodeCall(UpgradeManager.initialize, (_owner, _l1BuildAgent))
        });
        _addrs.upgradeManagerProxy = address(UpgradeManager(address(proxy)));
    }

    function _deploy_BedrockToGraniteImplementer() internal {
        _addrs.superchainConfig = address(new SuperchainConfig());
        _addrs.optimismPortal = address(new OasysPortal());
        _addrs.l2OutputOracle = address(new OasysL2OutputOracle());
        _addrs.systemConfig = address(new SystemConfig());
        _addrs.l1CrossDomainMessenger = address(new L1CrossDomainMessenger());
        _addrs.l1StandardBridge = address(new L1StandardBridge());
        _addrs.l1ERC721Bridge = address(new OasysL1ERC721Bridge());
        _addrs.bedrockToGranite = address(
            new BedrockToGranite({
                _superchainConfig: _addrs.superchainConfig,
                _optimismPortal: _addrs.optimismPortal,
                _l2OutputOracle: _addrs.l2OutputOracle,
                _systemConfig: _addrs.systemConfig,
                _l1CrossDomainMessenger: _addrs.l1CrossDomainMessenger,
                _l1StandardBridge: _addrs.l1StandardBridge,
                _l1ERC721Bridge: _addrs.l1ERC721Bridge
            })
        );
    }

    function _writeAddressesJson() internal {
        string memory json;
        json.serialize("UpgradeManagerProxy", _addrs.upgradeManagerProxy);
        json.serialize("BedrockToGranite", _addrs.bedrockToGranite);
        json.serialize("SuperchainConfig", _addrs.superchainConfig);
        json.serialize("OptimismPortal", _addrs.optimismPortal);
        json.serialize("L2OutputOracle", _addrs.l2OutputOracle);
        json.serialize("SystemConfig", _addrs.systemConfig);
        json.serialize("L1CrossDomainMessenger", _addrs.l1CrossDomainMessenger);
        json.serialize("L1StandardBridge", _addrs.l1StandardBridge);
        json.serialize("L1ERC721Bridge", _addrs.l1ERC721Bridge);
        json = json.serialize("SuperchainConfigProxy", _addrs.superchainConfigProxy);

        string memory path1 = string.concat(Path.upgradeLatestOutDir(), "/addresses.json");
        string memory path2 = string.concat(Path.upgradeRunOutDir(), "/addresses.json");
        json.write(path1);
        json.write(path2);
        console.log("Output: %s", path1);
        console.log("Output: %s", path2);
    }

    function _loadAddressesJson() internal {
        string memory path = string.concat(Path.upgradeLatestOutDir(), "/addresses.json");
        string memory json = vm.readFile(path);
        _addrs.upgradeManagerProxy = stdJson.readAddress(json, "$.UpgradeManagerProxy");
        _addrs.bedrockToGranite = stdJson.readAddress(json, "$.BedrockToGranite");
        _addrs.superchainConfig = stdJson.readAddress(json, "$.SuperchainConfig");
        _addrs.optimismPortal = stdJson.readAddress(json, "$.OptimismPortal");
        _addrs.l2OutputOracle = stdJson.readAddress(json, "$.L2OutputOracle");
        _addrs.systemConfig = stdJson.readAddress(json, "$.SystemConfig");
        _addrs.l1CrossDomainMessenger = stdJson.readAddress(json, "$.L1CrossDomainMessenger");
        _addrs.l1StandardBridge = stdJson.readAddress(json, "$.L1StandardBridge");
        _addrs.l1ERC721Bridge = stdJson.readAddress(json, "$.L1ERC721Bridge");
        _addrs.superchainConfigProxy = stdJson.readAddress(json, "$.SuperchainConfigProxy");
    }
}
