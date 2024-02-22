// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { L1BuildAgent } from "src/oasys/L1/build/L1BuildAgent.sol";
import { BuildProxy } from "src/oasys/L1/build/BuildProxy.sol";
import { BuildL1CrossDomainMessenger } from "src/oasys/L1/build/BuildL1CrossDomainMessenger.sol";
import { BuildL1ERC721Bridge } from "src/oasys/L1/build/BuildL1ERC721Bridge.sol";
import { BuildL1StandardBridge } from "src/oasys/L1/build/BuildL1StandardBridge.sol";
import { BuildOasysL2OutputOracle } from "src/oasys/L1/build/BuildOasysL2OutputOracle.sol";
import { BuildOasysPortal } from "src/oasys/L1/build/BuildOasysPortal.sol";
import { BuildSystemConfig } from "src/oasys/L1/build/BuildSystemConfig.sol";
import { BuildProtocolVersions } from "src/oasys/L1/build/BuildProtocolVersions.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";
import { Executables } from "scripts/Executables.sol";
import { Path } from "./_path.sol";

interface PermissionedContractFactory {
    /**
     * @dev creates a new contract using the `CREATE2` opcode.
     * Only callers granted with the `CONTRACT_CREATOR_ROLE` are permitted to call it.
     * The caller must send the expected new contract address for deployment.
     * If the expected address does not match the newly created one, the execution will be reverted.
     *
     * @param tag Registerd as metadata, we intended to set it as a contract name. this can be empty string
     *
     */
    function create(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode,
        address expected,
        string calldata tag
    )
        external
        payable
        returns (address addr);

    /**
     * @dev computes the address of a contract that would be created using the `CREATE2` opcode.
     * The address is computed using the provided salt and bytecode.
     */
    function getDeploymentAddress(bytes32 salt, bytes memory bytecode) external view returns (address addr);
}

contract Deploy is Script {
    using stdJson for string;

    bytes32 salt;
    PermissionedContractFactory pcc;
    ILegacyL1BuildAgent legacyL1BuildAgent;

    struct BuildContracts {
        address Proxy;
        address OutputOracle;
        address OasysPortal;
        address L1Messenger;
        address SystemConfig;
        address L1StandardBridg;
        address L1ERC721Bridge;
        address ProtocolVersions;
    }

    function setUp() public virtual {
        vm.createDir({ path: Path.deployOutDir(), recursive: true });

        salt = keccak256(bytes(vm.envString("SALT")));
        pcc = PermissionedContractFactory(0x520000000000000000000000000000000000002F);
        legacyL1BuildAgent = ILegacyL1BuildAgent(0x5200000000000000000000000000000000000008);

        console.log("Sender: %s", msg.sender);
        console.log("Salt: %s", vm.toString(salt));
    }

    function run() public {
        vm.startBroadcast();

        BuildContracts memory builts = _deployBuildContracts();

        bytes memory creationCode = type(L1BuildAgent).creationCode;
        bytes memory constructorArgs = abi.encode(
            builts.Proxy,
            builts.OutputOracle,
            builts.OasysPortal,
            builts.L1Messenger,
            builts.SystemConfig,
            builts.L1StandardBridg,
            builts.L1ERC721Bridge,
            builts.ProtocolVersions,
            legacyL1BuildAgent
        );
        address agent = _deploy("L1BuildAgent", abi.encodePacked(creationCode, constructorArgs));

        vm.stopBroadcast();

        _writeJson(agent, builts);

        console.log("Output: %s", Path.deployLatestOutPath());
        console.log("Output: %s", Path.deployRunOutPath());
    }

    function _deploy(string memory contractName, bytes memory deployBytecode) internal returns (address deployment) {
        deployment = pcc.getDeploymentAddress(salt, deployBytecode);
        pcc.create(0, salt, deployBytecode, deployment, contractName);
    }

    function _deployBuildContracts() internal returns (BuildContracts memory) {
        return BuildContracts({
            ProtocolVersions: _deploy("BuildProtocolVersions", type(BuildProtocolVersions).creationCode),
            Proxy: _deploy("BuildProxy", type(BuildProxy).creationCode),
            OutputOracle: _deploy("BuildL2OutputOracle", type(BuildOasysL2OutputOracle).creationCode),
            OasysPortal: _deploy("BuildOasysPortal", type(BuildOasysPortal).creationCode),
            L1Messenger: _deploy("BuildL1CrossDomainMessenger", type(BuildL1CrossDomainMessenger).creationCode),
            SystemConfig: _deploy("BuildSystemConfig", type(BuildSystemConfig).creationCode),
            L1StandardBridg: _deploy("BuildL1StandardBridge", type(BuildL1StandardBridge).creationCode),
            L1ERC721Bridge: _deploy("BuildL1ERC721Bridge", type(BuildL1ERC721Bridge).creationCode)
        });
    }

    function _writeJson(address agent, BuildContracts memory builts) internal {
        string memory json = ".";
        json.serialize("L1BuildAgent", agent);
        json.serialize("BuildProxy", builts.Proxy);
        json.serialize("BuildL2OutputOracle", builts.OutputOracle);
        json.serialize("BuildOasysPortal", builts.OasysPortal);
        json.serialize("BuildL1CrossDomainMessenger", builts.L1Messenger);
        json.serialize("BuildSystemConfig", builts.SystemConfig);
        json.serialize("BuildL1StandardBridge", builts.L1StandardBridg);
        json.serialize("BuildL1ERC721Bridge", builts.L1ERC721Bridge);
        json = json.serialize("BuildProtocolVersions", builts.ProtocolVersions);

        json.write(Path.deployLatestOutPath());
        json.write(Path.deployRunOutPath());
    }
}
