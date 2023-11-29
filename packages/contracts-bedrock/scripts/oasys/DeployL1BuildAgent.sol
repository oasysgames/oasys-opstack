// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/console2.sol";
import { L1BuildAgent } from "../../src/oasys/L1/build/L1BuildAgent.sol";
import { BuildL1CrossDomainMessenger } from "../../src/oasys/L1/build/BuildL1CrossDomainMessenger.sol";
import { BuildL1ERC721Bridge } from "../../src/oasys/L1/build/BuildL1ERC721Bridge.sol";
import { BuildL1StandardBridge } from "../../src/oasys/L1/build/BuildL1StandardBridge.sol";
import { BuildL2OutputOracle } from "../../src/oasys/L1/build/BuildL2OutputOracle.sol";
import { BuildOptimismPortal } from "../../src/oasys/L1/build/BuildOptimismPortal.sol";
import { BuildSystemConfig } from "../../src/oasys/L1/build/BuildSystemConfig.sol";
import { ILegacyL1BuildAgent } from "../../src/oasys/L1/build/interfaces/ILegacyL1BuildAgent.sol";
import { Executables } from "../../scripts/Executables.sol";

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

contract DeployL1BuildAgent is Script {
    bytes32 public salt = keccak256(bytes(vm.envString("SALT")));
    PermissionedContractFactory public pcc = PermissionedContractFactory(0x520000000000000000000000000000000000002F);
    ILegacyL1BuildAgent legacyL1BuildAgent = ILegacyL1BuildAgent(0x5200000000000000000000000000000000000008);

    function setUp() public virtual {
        console.log("Setup:");
        console.log("  sender: %s", msg.sender);
        console.log("  salt  : %s\n", vm.toString(salt));
    }

    function run() public {
        vm.startBroadcast();

        address _bOutputOracle = _deploy("BuildL2OutputOracle", type(BuildL2OutputOracle).creationCode);
        address _bOptimismPortal = _deploy("BuildOptimismPortal", type(BuildOptimismPortal).creationCode);
        address _bL1Messenger = _deploy("BuildL1CrossDomainMessenger", type(BuildL1CrossDomainMessenger).creationCode);
        address _bSystemConfig = _deploy("BuildSystemConfig", type(BuildSystemConfig).creationCode);
        address _bL1StandardBridg = _deploy("BuildL1StandardBridge", type(BuildL1StandardBridge).creationCode);
        address _bL1ERC721Bridge = _deploy("BuildL1ERC721Bridge", type(BuildL1ERC721Bridge).creationCode);

        bytes memory creationCode = type(L1BuildAgent).creationCode;
        bytes memory constructorArgs = abi.encode(
            _bOutputOracle,
            _bOptimismPortal,
            _bL1Messenger,
            _bSystemConfig,
            _bL1StandardBridg,
            _bL1ERC721Bridge,
            legacyL1BuildAgent
        );
        address agent = _deploy("L1BuildAgent", abi.encodePacked(creationCode, constructorArgs));

        vm.stopBroadcast();

        console.log("Deployed contracts:");
        console.log("  BuildL2OutputOracle        : %s", _bOutputOracle);
        console.log("  BuildOptimismPortal        : %s", _bOptimismPortal);
        console.log("  BuildL1CrossDomainMessenger: %s", _bL1Messenger);
        console.log("  BuildSystemConfig          : %s", _bSystemConfig);
        console.log("  BuildL1StandardBridge      : %s", _bL1StandardBridg);
        console.log("  BuildL1ERC721Bridge        : %s", _bL1ERC721Bridge);
        console.log("  L1BuildAgent               : %s", agent);
    }

    function _deploy(string memory contractName, bytes memory deployBytecode) internal returns (address deployment) {
        deployment = pcc.getDeploymentAddress(salt, deployBytecode);
        pcc.create(0, salt, deployBytecode, deployment, contractName);
    }
}
