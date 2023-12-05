// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { VmSafe } from "forge-std/Vm.sol";

library Path {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    function outDir() internal view returns (string memory) {
        return string.concat(vm.projectRoot(), "/tmp/oasys/L1/build");
    }

    // Using from Deploy.s.sol;
    function deployOutDir() internal view returns (string memory) {
        return string.concat(outDir(), "/Deploy.s.sol");
    }

    function deployLatestOutPath() internal view returns (string memory) {
        return string.concat(deployOutDir(), "/latest.json");
    }

    function deployRunOutPath() internal view returns (string memory) {
        return string.concat(deployOutDir(), "/run-", vm.toString(block.number), ".json");
    }

    // Using from Build.s.sol;
    function buildOutDir() internal view returns (string memory) {
        return string.concat(outDir(), "/Build.s.sol");
    }

    function buildLatestOutDir() internal view returns (string memory) {
        return string.concat(buildOutDir(), "/latest");
    }

    function buildRunOutDir() internal view returns (string memory) {
        return string.concat(buildOutDir(), "/run-", vm.toString(block.number));
    }
}
