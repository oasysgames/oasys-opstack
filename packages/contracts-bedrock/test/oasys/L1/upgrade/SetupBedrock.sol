// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Testing utilities
import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { stdJson } from "forge-std/StdJson.sol";

// Libraries
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { console2 as console } from "forge-std/console2.sol";

// Target contract dependencies
import { Proxy } from "src/universal/Proxy.sol";

import { MockLegacyL1BuildAgent } from "test/setup/oasys/MockLegacyL1BuildAgent.sol";
import { MockLegacyL1BuildDeposit } from "test/setup/oasys/MockLegacyL1BuildDeposit.sol";
import { IL1BuildAgent } from "src/oasys/L1/build/interfaces/IL1BuildAgent.sol";
import { IL1BuildDeposit } from "src/oasys/L1/build/interfaces/IL1BuildDeposit.sol";

contract SetupL1BuildAgent is Test {
    using stdJson for string;

    bytes32 public constant CREATE2_SALT = keccak256("SetupL1BuildAgent");

    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    function deploy() external returns (IL1BuildAgent buildAgent, IL1BuildDeposit buildDeposit) {
        Proxy buildAgentProxy = new Proxy({ _admin: deployer });
        Proxy buildDepositProxy = new Proxy({ _admin: deployer });

        _deployBuildAgent(buildAgentProxy, buildDepositProxy);
        _deployBuildDeposit(buildAgentProxy, buildDepositProxy);

        buildAgent = IL1BuildAgent(address(buildAgentProxy));
        buildDeposit = IL1BuildDeposit(address(buildDepositProxy));
    }

    function _deployBuildAgent(Proxy _buildAgentProxy, Proxy _buildDepositProxy) internal {
        vm.prank(deployer);
        address legacyBuildAgent = address(new MockLegacyL1BuildAgent());
        console.log("legacyBuildAgent: %s", legacyBuildAgent);

        (bytes memory packed, address l2ooVerifier) = _deployDependencies();

        address buildAgentImpl = _deploy(
            abi.encodePacked(
                _readBytecode("L1BuildAgent"),
                abi.encodePacked(
                    packed,
                    abi.encode(
                        address(_buildDepositProxy), // _l1BuildDeposit,
                        legacyBuildAgent, // _legacyL1BuildAgent,
                        l2ooVerifier // _l2ooVerifier
                    )
                )
            )
        );
        console.log("buildAgentImpl: %s", buildAgentImpl);

        vm.prank(deployer);
        _buildAgentProxy.upgradeTo({ _implementation: buildAgentImpl });
    }

    function _deployBuildDeposit(Proxy _buildAgentProxy, Proxy _buildDepositProxy) internal {
        vm.prank(deployer);
        address legacyBuildDeposit = address(new MockLegacyL1BuildDeposit());
        console.log("legacyBuildDeposit: %s", legacyBuildDeposit);

        address buildDepositImpl = _deploy(
            abi.encodePacked(
                _readBytecode("L1BuildDeposit"),
                abi.encode(
                    1 ether, // _requiredAmount
                    1, // _lockedBlock
                    address(_buildAgentProxy), // _agentAddress
                    legacyBuildDeposit // _legacyL1BuildDeposit
                )
            )
        );
        console.log("buildDepositImpl: %s", buildDepositImpl);

        vm.prank(deployer);
        _buildDepositProxy.upgradeTo({ _implementation: buildDepositImpl });
    }

    function _deployDependencies() internal returns (bytes memory packed, address l2ooVerifier) {
        address bProxy = _deploy(_readBytecode("BuildProxy"));
        console.log("Proxy: %s", bProxy);

        address bOasysL2OO = _deploy(_readBytecode("BuildOasysL2OutputOracle"));
        console.log("OasysL2OO: %s", bOasysL2OO);

        address bOasysPortal = _deploy(_readBytecode("BuildOasysPortal"));
        console.log("OasysPortal: %s", bOasysPortal);

        address bL1CrossDomainMessenger = _deploy(_readBytecode("BuildL1CrossDomainMessenger"));
        console.log("L1CrossDomainMessenger: %s", bL1CrossDomainMessenger);

        address bSystemConfig = _deploy(_readBytecode("BuildSystemConfig"));
        console.log("SystemConfig: %s", bSystemConfig);

        address bL1StandardBridg = _deploy(_readBytecode("BuildL1StandardBridge"));
        console.log("L1StandardBridg: %s", bL1StandardBridg);

        address bOasysL1ERC721Bridge = _deploy(_readBytecode("BuildOasysL1ERC721Bridge"));
        console.log("OasysL1ERC721Bridge: %s", bOasysL1ERC721Bridge);

        address bProtocolVersions = _deploy(_readBytecode("BuildProtocolVersions"));
        console.log("ProtocolVersions: %s", bProtocolVersions);

        l2ooVerifier = _deploy(_readBytecode("OasysL2OutputOracleVerifier"));
        console.log("OasysL2OOVerifier: %s", l2ooVerifier);

        packed = abi.encode(
            bProxy, // _bProxy,
            bOasysL2OO, // _bOasysL2OO,
            bOasysPortal, // _bOasysPortal,
            bL1CrossDomainMessenger, // _bL1CrossDomainMessenger,
            bSystemConfig, // _bSystemConfig,
            bL1StandardBridg, // _bL1StandardBridg,
            bOasysL1ERC721Bridge, // _bOasysL1ERC721Bridge,
            bProtocolVersions // _bProtocolVersions,
                // _l1BuildDeposit,
                // _legacyL1BuildAgent,
                // _l2ooVerifier
        );
    }

    function _readBytecode(string memory name) internal view returns (bytes memory) {
        string memory artifact =
            string.concat(vm.projectRoot(), "/test/oasys/L1/upgrade/artifacts/bedrock", "/", name, ".json");
        return vm.readFile(artifact).readBytes("$.bytecode.object");
    }

    function _deploy(bytes memory _bytecode) internal returns (address) {
        vm.prank(deployer);
        return Create2.deploy(0, CREATE2_SALT, _bytecode);
    }

    function _computeAddress(bytes memory _bytecode) internal view returns (address) {
        return Create2.computeAddress(CREATE2_SALT, keccak256(_bytecode), deployer);
    }
}
