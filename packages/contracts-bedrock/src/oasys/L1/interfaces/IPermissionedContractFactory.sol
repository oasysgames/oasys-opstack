// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPermissionedContractFactory {
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
