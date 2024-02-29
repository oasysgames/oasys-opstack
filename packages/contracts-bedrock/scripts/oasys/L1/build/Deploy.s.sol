// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { L1BuildAgent } from "src/oasys/L1/build/L1BuildAgent.sol";
import { L1BuildDeposit } from "src/oasys/L1/build/L1BuildDeposit.sol";
import { OasysL2OutputOracleVerifier } from "src/oasys/L1/rollup/OasysL2OutputOracleVerifier.sol";
import { BuildProxy } from "src/oasys/L1/build/BuildProxy.sol";
import { BuildL1CrossDomainMessenger } from "src/oasys/L1/build/BuildL1CrossDomainMessenger.sol";
import { BuildL1ERC721Bridge } from "src/oasys/L1/build/BuildL1ERC721Bridge.sol";
import { BuildL1StandardBridge } from "src/oasys/L1/build/BuildL1StandardBridge.sol";
import { BuildOasysL2OutputOracle } from "src/oasys/L1/build/BuildOasysL2OutputOracle.sol";
import { BuildOasysPortal } from "src/oasys/L1/build/BuildOasysPortal.sol";
import { BuildSystemConfig } from "src/oasys/L1/build/BuildSystemConfig.sol";
import { BuildProtocolVersions } from "src/oasys/L1/build/BuildProtocolVersions.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";
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
    IL1BuildAgent legacyL1BuildAgent;
    IL1BuildDeposit legacyL1BuildDeposit;

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
        legacyL1BuildAgent = IL1BuildAgent(0x5200000000000000000000000000000000000008);
        legacyL1BuildDeposit = IL1BuildDeposit(0x5200000000000000000000000000000000000007);

        console.log("Sender: %s", msg.sender);
        console.log("Salt: %s", vm.toString(salt));
    }

    function run() public {
        vm.startBroadcast();

        BuildContracts memory builts = _deployBuildContracts();

        (address pAgent, address pDeposit, address pL2ooVerifier) = _deployProxies();
        _initL1BuildDeposit(pDeposit, pAgent);
        _initL2ooVerifier(pL2ooVerifier);
        _initL1BuildAgent(
            builts.Proxy,
            builts.OutputOracle,
            builts.OasysPortal,
            builts.L1Messenger,
            builts.SystemConfig,
            builts.L1StandardBridg,
            builts.L1ERC721Bridge,
            builts.ProtocolVersions,
            pAgent,
            pDeposit,
            pL2ooVerifier
        );

        vm.stopBroadcast();

        _writeJson(pAgent, pDeposit, pL2ooVerifier, builts);

        console.log("Output: %s", Path.deployLatestOutPath());
        console.log("Output: %s", Path.deployRunOutPath());
    }

    function _deploy(string memory contractName, bytes memory deployBytecode) internal returns (address deployment) {
        deployment = pcc.getDeploymentAddress(salt, deployBytecode);
        pcc.create(0, salt, deployBytecode, deployment, contractName);
    }

    function _deployWithCustomSalt(
        string memory contractName,
        bytes memory deployBytecode,
        bytes32 _salt
    )
        internal
        returns (address deployment)
    {
        deployment = pcc.getDeploymentAddress(_salt, deployBytecode);
        pcc.create(0, _salt, deployBytecode, deployment, contractName);
    }

    // Deploy proxies for L1BuildDeposit and L1BuildAgent and OasysL2OutputOracleVerifier
    function _deployProxies() internal returns (address, address, address) {
        // Authorized to upgrade L1BuildAgent and L1BuildDeposit and OasysL2OutputOracleVerifier
        address admin = msg.sender;
        address pAgent = _deployWithCustomSalt(
            "Proxy",
            abi.encodePacked(type(Proxy).creationCode, abi.encode(admin)),
            0x0000000000000000000000000000000000000000000000000000000000000001
        );
        address pDeposit = _deployWithCustomSalt(
            "Proxy",
            abi.encodePacked(type(Proxy).creationCode, abi.encode(admin)),
            0x0000000000000000000000000000000000000000000000000000000000000002
        );
        address pL2ooVerifier = _deployWithCustomSalt(
            "Proxy",
            abi.encodePacked(type(Proxy).creationCode, abi.encode(admin)),
            0x0000000000000000000000000000000000000000000000000000000000000003
        );
        return (pAgent, pDeposit, pL2ooVerifier);
    }

    function _initL1BuildDeposit(address pDeposit, address agent) internal {
        // Deploy L1BuildDeposit
        address deposit = _deploy(
            "L1BuildDeposit",
            abi.encodePacked(
                type(L1BuildDeposit).creationCode,
                abi.encode(
                    1 ether, // requiredAmount,
                    100, // lockedBlock,
                    agent,
                    legacyL1BuildDeposit
                )
            )
        );

        // Set implementation of L1BuildDeposit
        address[] memory addresses = new address[](1);
        addresses[0] = 0x5200000000000000000000000000000000000002; // sOAS
        bytes memory initCall = abi.encodeWithSignature("initialize(address[])", addresses);
        Proxy(payable(pDeposit)).upgradeToAndCall(deposit, initCall);
    }

    function _initL2ooVerifier(address pL2ooVerifier) internal {
        bytes memory creationCode = type(OasysL2OutputOracleVerifier).creationCode;
        address impl = _deploy("OasysL2OutputOracleVerifier", abi.encodePacked(creationCode));
        Proxy(payable(pL2ooVerifier)).upgradeTo(impl);
    }

    function _initL1BuildAgent(
        address _bProxy,
        address _bOutputOracle,
        address _bOptimismPortal,
        address _bL1Messenger,
        address _bSystemConfig,
        address _bL1StandardBridg,
        address _bL1ERC721Bridge,
        address _bProtocolVersions,
        address pAgent,
        address pDeposit,
        address pL2ooVerifier
    )
        internal
    {
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
            pDeposit,
            legacyL1BuildAgent,
            pL2ooVerifier
        );
        address agent = _deploy("L1BuildAgent", abi.encodePacked(creationCode, constructorArgs));
        Proxy(payable(pAgent)).upgradeTo(agent);
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

    function _writeJson(
        address pAgent,
        address pDeposit,
        address pL2ooVerifier,
        BuildContracts memory builts
    )
        internal
    {
        string memory json = ".";
        json.serialize("L1BuildAgent", pAgent);
        json.serialize("L1BuildDeposit", pDeposit);
        json.serialize("OasysL2OutputOracleVerifier", pL2ooVerifier);
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
