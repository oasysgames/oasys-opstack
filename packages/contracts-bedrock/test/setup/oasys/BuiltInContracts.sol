// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

library BuiltInContracts {
    function PermissionedContractFactoryBytecode(
        address[] memory admins,
        address[] memory creators
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            // commit:https://github.com/oasysgames/oasys-governance-contract/blob/be1dff6c29cd84c671ab3f4e0cfb811a0e47634f/contracts/PermissionedContractFactory.sol
            hex"60806040523480156200001157600080fd5b5060405162001829380380620018298339810160408190526200003491620003eb565b6200004160008062000210565b6200005d60008051602062001809833981519152600062000210565b60005b82518160ff161015620001325760006001600160a01b0316838260ff168151811062000090576200009062000455565b60200260200101516001600160a01b031603620000e95760405162461bcd60e51b81526020600482015260126024820152715043433a2061646d696e206973207a65726f60701b60448201526064015b60405180910390fd5b6200011d6000801b848360ff168151811062000109576200010962000455565b60200260200101516200025b60201b60201c565b8062000129816200046b565b91505062000060565b5060005b81518160ff161015620002075760006001600160a01b0316828260ff168151811062000166576200016662000455565b60200260200101516001600160a01b031603620001c65760405162461bcd60e51b815260206004820152601460248201527f5043433a2063726561746f72206973207a65726f0000000000000000000000006044820152606401620000e0565b620001f260008051602062001809833981519152838360ff168151811062000109576200010962000455565b80620001fe816200046b565b91505062000136565b50505062000499565b600082815260208190526040808220600101805490849055905190918391839186917fbd79b86ffe0ab8e8776151514217cd7cacd52c909f66475c3af44e129f0b00ff9190a4505050565b6200026782826200026b565b5050565b6000828152602081815260408083206001600160a01b038516845290915290205460ff1662000267576000828152602081815260408083206001600160a01b03851684529091529020805460ff19166001179055620002c73390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45050565b634e487b7160e01b600052604160045260246000fd5b80516001600160a01b03811681146200033957600080fd5b919050565b600082601f8301126200035057600080fd5b815160206001600160401b03808311156200036f576200036f6200030b565b8260051b604051601f19603f830116810181811084821117156200039757620003976200030b565b604052938452858101830193838101925087851115620003b657600080fd5b83870191505b84821015620003e057620003d08262000321565b83529183019190830190620003bc565b979650505050505050565b60008060408385031215620003ff57600080fd5b82516001600160401b03808211156200041757600080fd5b62000425868387016200033e565b935060208501519150808211156200043c57600080fd5b506200044b858286016200033e565b9150509250929050565b634e487b7160e01b600052603260045260246000fd5b600060ff821660ff81036200049057634e487b7160e01b600052601160045260246000fd5b60010192915050565b61136080620004a96000396000f3fe6080604052600436106100b25760003560e01c806336568abe1161006f57806336568abe146101e55780634de79ecc1461020557806365ddb0171461021a57806391d148541461022d578063a217fddf1461024d578063d547741f14610262578063da58f37e1461028257600080fd5b806301ffc9a7146100b757806309b1eca6146100ec5780630b19429e14610124578063248a9ca3146101665780632a50c146146101965780632f2ff15d146101c3575b600080fd5b3480156100c357600080fd5b506100d76100d2366004610d98565b6102a2565b60405190151581526020015b60405180910390f35b3480156100f857600080fd5b5061010c610107366004610e65565b6102d9565b6040516001600160a01b0390911681526020016100e3565b34801561013057600080fd5b506101587f0d8b58cba732a42811e1f217ab43cccb14f1a8263ebb61afbf13838fcdae9df981565b6040519081526020016100e3565b34801561017257600080fd5b50610158610181366004610eac565b60009081526020819052604090206001015490565b3480156101a257600080fd5b506101b66101b1366004610edc565b6102f4565b6040516100e39190610f47565b3480156101cf57600080fd5b506101e36101de366004610f8a565b610433565b005b3480156101f157600080fd5b506101e3610200366004610f8a565b61045d565b34801561021157600080fd5b50600154610158565b61010c610228366004610fb6565b6104db565b34801561023957600080fd5b506100d7610248366004610f8a565b610614565b34801561025957600080fd5b50610158600081565b34801561026e57600080fd5b506101e361027d366004610f8a565b61063d565b34801561028e57600080fd5b506101b661029d366004610eac565b610662565b60006001600160e01b03198216637965db0b60e01b14806102d357506301ffc9a760e01b6001600160e01b03198316145b92915050565b60006102ed838380519060200120306107ca565b9392505050565b604080516060808201835260008083526020830152918101919091526001600160a01b0380831660009081526002602081815260409283902083516060810185528154861681526001820154909516918501919091529081018054919284019161035d90611070565b80601f016020809104026020016040519081016040528092919081815260200182805461038990611070565b80156103d65780601f106103ab576101008083540402835291602001916103d6565b820191906000526020600020905b8154815290600101906020018083116103b957829003601f168201915b5050509190925250505060208101519091506001600160a01b031661042e5760405162461bcd60e51b81526020600482015260096024820152681b9bdd08199bdd5b9960ba1b60448201526064015b60405180910390fd5b919050565b60008281526020819052604090206001015461044e816107f4565b6104588383610801565b505050565b6001600160a01b03811633146104cd5760405162461bcd60e51b815260206004820152602f60248201527f416363657373436f6e74726f6c3a2063616e206f6e6c792072656e6f756e636560448201526e103937b632b9903337b91039b2b63360891b6064820152608401610425565b6104d78282610885565b5050565b60007f0d8b58cba732a42811e1f217ab43cccb14f1a8263ebb61afbf13838fcdae9df9610507816107f4565b8734146105565760405162461bcd60e51b815260206004820152601a60248201527f5043433a20696e636f727265637420616d6f756e742073656e740000000000006044820152606401610425565b6105618888886108ea565b9150846001600160a01b0316826001600160a01b0316146105be5760405162461bcd60e51b81526020600482015260176024820152765043433a20756e6578706563746564206164647265737360481b6044820152606401610425565b7f388d923fb867b31389c9da49a5a9b552bd44cde0717beb38a215d99ef09778db33898989866040516105f59594939291906110aa565b60405180910390a1610609823386866109ea565b509695505050505050565b6000918252602082815260408084206001600160a01b0393909316845291905290205460ff1690565b600082815260208190526040902060010154610658816107f4565b6104588383610885565b6040805160608082018352600080835260208301529181019190915260015461068c836001611103565b11156106cf5760405162461bcd60e51b8152602060048201526012602482015271696e646578206f7574206f662072616e676560701b6044820152606401610425565b60026000600184815481106106e6576106e6611116565b60009182526020808320909101546001600160a01b0390811684528382019490945260409283019091208251606081018452815485168152600182015490941691840191909152600281018054919284019161074190611070565b80601f016020809104026020016040519081016040528092919081815260200182805461076d90611070565b80156107ba5780601f1061078f576101008083540402835291602001916107ba565b820191906000526020600020905b81548152906001019060200180831161079d57829003601f168201915b5050505050815250509050919050565b6000604051836040820152846020820152828152600b8101905060ff815360559020949350505050565b6107fe8133610b91565b50565b61080b8282610614565b6104d7576000828152602081815260408083206001600160a01b03851684529091529020805460ff191660011790556108413390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45050565b61088f8282610614565b156104d7576000828152602081815260408083206001600160a01b0385168085529252808320805460ff1916905551339285917ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b9190a45050565b60008347101561093c5760405162461bcd60e51b815260206004820152601d60248201527f437265617465323a20696e73756666696369656e742062616c616e63650000006044820152606401610425565b815160000361098d5760405162461bcd60e51b815260206004820181905260248201527f437265617465323a2062797465636f6465206c656e677468206973207a65726f6044820152606401610425565b8282516020840186f590506001600160a01b0381166102ed5760405162461bcd60e51b8152602060048201526019602482015278437265617465323a204661696c6564206f6e206465706c6f7960381b6044820152606401610425565b6001600160a01b038481166000908152600260205260409020600101541615610a4a5760405162461bcd60e51b8152602060048201526012602482015271185b1c9958591e481c9959da5cdd195c995960721b6044820152606401610425565b826001600160a01b03167f8d3f2558914d24d1627609279aec4a8b1033bb2e86f4fc8118aba14785e3fc39858484604051610a879392919061112c565b60405180910390a26001805480820182556000919091527fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf60180546001600160a01b0319166001600160a01b03868116918217909255604080516060810182529182529185166020808301919091528251601f85018290048202810182018452848152919283019190859085908190840183828082843760009201829052509390945250506001600160a01b03808816825260026020818152604093849020865181549085166001600160a01b031991821617825591870151600182018054919095169216919091179092559184015190925090820190610b8890826111ba565b50505050505050565b610b9b8282610614565b6104d757610ba881610bea565b610bb3836020610bfc565b604051602001610bc492919061127a565b60408051601f198184030181529082905262461bcd60e51b8252610425916004016112e9565b60606102d36001600160a01b03831660145b60606000610c0b8360026112fc565b610c16906002611103565b67ffffffffffffffff811115610c2e57610c2e610dc2565b6040519080825280601f01601f191660200182016040528015610c58576020820181803683370190505b509050600360fc1b81600081518110610c7357610c73611116565b60200101906001600160f81b031916908160001a905350600f60fb1b81600181518110610ca257610ca2611116565b60200101906001600160f81b031916908160001a9053506000610cc68460026112fc565b610cd1906001611103565b90505b6001811115610d49576f181899199a1a9b1b9c1cb0b131b232b360811b85600f1660108110610d0557610d05611116565b1a60f81b828281518110610d1b57610d1b611116565b60200101906001600160f81b031916908160001a90535060049490941c93610d4281611313565b9050610cd4565b5083156102ed5760405162461bcd60e51b815260206004820181905260248201527f537472696e67733a20686578206c656e67746820696e73756666696369656e746044820152606401610425565b600060208284031215610daa57600080fd5b81356001600160e01b0319811681146102ed57600080fd5b634e487b7160e01b600052604160045260246000fd5b600082601f830112610de957600080fd5b813567ffffffffffffffff80821115610e0457610e04610dc2565b604051601f8301601f19908116603f01168101908282118183101715610e2c57610e2c610dc2565b81604052838152866020858801011115610e4557600080fd5b836020870160208301376000602085830101528094505050505092915050565b60008060408385031215610e7857600080fd5b82359150602083013567ffffffffffffffff811115610e9657600080fd5b610ea285828601610dd8565b9150509250929050565b600060208284031215610ebe57600080fd5b5035919050565b80356001600160a01b038116811461042e57600080fd5b600060208284031215610eee57600080fd5b6102ed82610ec5565b60005b83811015610f12578181015183820152602001610efa565b50506000910152565b60008151808452610f33816020860160208601610ef7565b601f01601f19169290920160200192915050565b60208152600060018060a01b03808451166020840152806020850151166040840152506040830151606080840152610f826080840182610f1b565b949350505050565b60008060408385031215610f9d57600080fd5b82359150610fad60208401610ec5565b90509250929050565b60008060008060008060a08789031215610fcf57600080fd5b8635955060208701359450604087013567ffffffffffffffff80821115610ff557600080fd5b6110018a838b01610dd8565b955061100f60608a01610ec5565b9450608089013591508082111561102557600080fd5b818901915089601f83011261103957600080fd5b81358181111561104857600080fd5b8a602082850101111561105a57600080fd5b6020830194508093505050509295509295509295565b600181811c9082168061108457607f821691505b6020821081036110a457634e487b7160e01b600052602260045260246000fd5b50919050565b600060018060a01b03808816835286602084015285604084015260a060608401526110d860a0840186610f1b565b91508084166080840152509695505050505050565b634e487b7160e01b600052601160045260246000fd5b808201808211156102d3576102d36110ed565b634e487b7160e01b600052603260045260246000fd5b6001600160a01b03841681526040602082018190528101829052818360608301376000818301606090810191909152601f909201601f1916010192915050565b601f82111561045857600081815260208120601f850160051c810160208610156111935750805b601f850160051c820191505b818110156111b25782815560010161119f565b505050505050565b815167ffffffffffffffff8111156111d4576111d4610dc2565b6111e8816111e28454611070565b8461116c565b602080601f83116001811461121d57600084156112055750858301515b600019600386901b1c1916600185901b1785556111b2565b600085815260208120601f198616915b8281101561124c5788860151825594840194600190910190840161122d565b508582101561126a5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b76020b1b1b2b9b9a1b7b73a3937b61d1030b1b1b7bab73a1604d1b8152600083516112ac816017850160208801610ef7565b7001034b99036b4b9b9b4b733903937b6329607d1b60179184019182015283516112dd816028840160208801610ef7565b01602801949350505050565b6020815260006102ed6020830184610f1b565b80820281158282048414176102d3576102d36110ed565b600081611322576113226110ed565b50600019019056fea26469706673582212206921a9f7c5bb12866f25cbc8403a852dd261b38e2deb870825f95c96e3b64db864736f6c634300081200330d8b58cba732a42811e1f217ab43cccb14f1a8263ebb61afbf13838fcdae9df9",
            abi.encode(admins, creators)
        );
    }
}