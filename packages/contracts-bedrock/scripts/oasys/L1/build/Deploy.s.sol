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
import { BuildL2OutputOracle } from "src/oasys/L1/build/BuildL2OutputOracle.sol";
import { BuildOptimismPortal } from "src/oasys/L1/build/BuildOptimismPortal.sol";
import { BuildSystemConfig } from "src/oasys/L1/build/BuildSystemConfig.sol";
import { BuildProtocolVersions } from "src/oasys/L1/build/BuildProtocolVersions.sol";
import { ILegacyL1BuildAgent } from "src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";
import { MockL1BuildDeposit } from "src/oasys/L1/build/legacy/MockL1BuildDeposit.sol";
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

        address _bProxy = _deploy("BuildProxy", type(BuildProxy).creationCode);
        address _bOutputOracle = _deploy("BuildL2OutputOracle", type(BuildL2OutputOracle).creationCode);
        address _bOptimismPortal = _deploy("BuildOptimismPortal", type(BuildOptimismPortal).creationCode);
        address _bL1Messenger = _deploy("BuildL1CrossDomainMessenger", type(BuildL1CrossDomainMessenger).creationCode);
        address _bSystemConfig = _deploy("BuildSystemConfig", type(BuildSystemConfig).creationCode);
        address _bL1StandardBridg = _deploy("BuildL1StandardBridge", type(BuildL1StandardBridge).creationCode);
        address _bL1ERC721Bridge = _deploy("BuildL1ERC721Bridge", type(BuildL1ERC721Bridge).creationCode);
        address _bProtocolVersions = _deploy("BuildProtocolVersions", type(BuildProtocolVersions).creationCode);

        uint256 _requiredAmount = 1 ether;
        address _l1BuildDeposit = _deploy("MockL1BuildDeposit", abi.encodePacked(type(MockL1BuildDeposit).creationCode, abi.encode(_requiredAmount)));

        bytes memory creationCode = type(L1BuildAgent).creationCode;
        bytes memory constructorArgs = abi.encode(
            _bProxy,
            _bOutputOracle,
            _bOptimismPortal,
            _bL1Messenger,
            _bSystemConfig,
            _bL1StandardBridg,
            _bL1ERC721Bridge,
            _bProtocolVersions,
            legacyL1BuildAgent,
            _l1BuildDeposit
        );
        address agent = _deploy("L1BuildAgent", abi.encodePacked(creationCode, constructorArgs));

        vm.stopBroadcast();

        string memory json = ".";
        json.serialize("BuildProxy", _bProxy);
        json.serialize("BuildL2OutputOracle", _bOutputOracle);
        json.serialize("BuildOptimismPortal", _bOptimismPortal);
        json.serialize("BuildL1CrossDomainMessenger", _bL1Messenger);
        json.serialize("BuildSystemConfig", _bSystemConfig);
        json.serialize("BuildL1StandardBridge", _bL1StandardBridg);
        json.serialize("BuildL1ERC721Bridge", _bL1ERC721Bridge);
        json.serialize("BuildProtocolVersions", _bProtocolVersions);
        json.serialize("L1BuildDeposit", _l1BuildDeposit);
        json = json.serialize("L1BuildAgent", agent);

        json.write(Path.deployLatestOutPath());
        json.write(Path.deployRunOutPath());

        console.log("Output: %s", Path.deployLatestOutPath());
        console.log("Output: %s", Path.deployRunOutPath());
    }

    function _deploy(string memory contractName, bytes memory deployBytecode) internal returns (address deployment) {
        deployment = pcc.getDeploymentAddress(salt, deployBytecode);
        pcc.create(0, salt, deployBytecode, deployment, contractName);
    }
}
