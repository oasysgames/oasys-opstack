// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package bindings

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
)

// OasysL2ERC721BridgeMetaData contains all meta data concerning the OasysL2ERC721Bridge contract.
var OasysL2ERC721BridgeMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"constructor\",\"inputs\":[{\"name\":\"_messenger\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_otherBridge\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"MESSENGER\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractCrossDomainMessenger\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"OTHER_BRIDGE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"bridgeERC721\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_minGasLimit\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"bridgeERC721To\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_minGasLimit\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"deposits\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"finalizeBridgeERC721\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"finalizeDeposit\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"l1ERC721Bridge\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"messenger\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractCrossDomainMessenger\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"otherBridge\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"version\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"string\",\"internalType\":\"string\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"withdraw\",\"inputs\":[{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_l1Gas\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"withdrawTo\",\"inputs\":[{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_l1Gas\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"event\",\"name\":\"DepositFailed\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DepositFinalized\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ERC721BridgeFinalized\",\"inputs\":[{\"name\":\"localToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"remoteToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"extraData\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ERC721BridgeInitiated\",\"inputs\":[{\"name\":\"localToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"remoteToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"extraData\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"WithdrawalInitiated\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false}]",
	Bin: "0x60c06040523480156200001157600080fd5b5060405162001a3538038062001a35833981016040819052620000349162000153565b818181816001600160a01b038216620000a95760405162461bcd60e51b815260206004820152602c60248201527f4552433732314272696467653a206d657373656e6765722063616e6e6f74206260448201526b65206164647265737328302960a01b60648201526084015b60405180910390fd5b6001600160a01b038116620001195760405162461bcd60e51b815260206004820152602f60248201527f4552433732314272696467653a206f74686572206272696467652063616e6e6f60448201526e74206265206164647265737328302960881b6064820152608401620000a0565b6001600160a01b039182166080521660a052506200018b92505050565b80516001600160a01b03811681146200014e57600080fd5b919050565b600080604083850312156200016757600080fd5b620001728362000136565b9150620001826020840162000136565b90509250929050565b60805160a051611853620001e2600039600081816101fd0152818161026e0152818161042e0152610c5101526000818161010e0152818161022401528181610404015281816104650152610c2401526118536000f3fe608060405234801561001057600080fd5b50600436106100df5760003560e01c8063761f44931161008c578063a3a7954811610066578063a3a7954814610246578063aa55745214610259578063c4e8ddfa1461026c578063c89701a21461026c57600080fd5b8063761f4493146101e55780637f46ddb2146101f8578063927ede2d1461021f57600080fd5b806354fd4d50116100bd57806354fd4d50146101585780635d93a3fc146101a1578063662a633a146101e557600080fd5b806332b7006d146100e45780633687011a146100f95780633cb747bf1461010c575b600080fd5b6100f76100f236600461143c565b610292565b005b6100f76101073660046114ad565b610345565b7f00000000000000000000000000000000000000000000000000000000000000005b60405173ffffffffffffffffffffffffffffffffffffffff90911681526020015b60405180910390f35b6101946040518060400160405280600581526020017f312e352e3000000000000000000000000000000000000000000000000000000081525081565b60405161014f919061159b565b6101d56101af3660046115ae565b600260209081526000938452604080852082529284528284209052825290205460ff1681565b604051901515815260200161014f565b6100f76101f33660046115ef565b6103ec565b61012e7f000000000000000000000000000000000000000000000000000000000000000081565b61012e7f000000000000000000000000000000000000000000000000000000000000000081565b6100f76102543660046114ad565b6105ae565b6100f7610267366004611687565b610669565b7f000000000000000000000000000000000000000000000000000000000000000061012e565b333b15610326576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602d60248201527f4552433732314272696467653a206163636f756e74206973206e6f742065787460448201527f65726e616c6c79206f776e65640000000000000000000000000000000000000060648201526084015b60405180910390fd5b61033e856103338761071c565b333388888888610887565b5050505050565b333b156103d4576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602d60248201527f4552433732314272696467653a206163636f756e74206973206e6f742065787460448201527f65726e616c6c79206f776e656400000000000000000000000000000000000000606482015260840161031d565b6103e48686333388888888610887565b505050505050565b3373ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001614801561050a57507f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff167f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff16636e296e456040518163ffffffff1660e01b8152600401602060405180830381865afa1580156104ce573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104f291906116fe565b73ffffffffffffffffffffffffffffffffffffffff16145b610596576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603f60248201527f4552433732314272696467653a2066756e6374696f6e2063616e206f6e6c792060448201527f62652063616c6c65642066726f6d20746865206f746865722062726964676500606482015260840161031d565b6105a587878787878787610dbe565b50505050505050565b73ffffffffffffffffffffffffffffffffffffffff8516610651576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603260248201527f4c324552433732314272696467653a206e667420726563697069656e7420636160448201527f6e6e6f7420626520616464726573732830290000000000000000000000000000606482015260840161031d565b6103e48661065e8861071c565b338888888888610887565b73ffffffffffffffffffffffffffffffffffffffff851661070c576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603060248201527f4552433732314272696467653a206e667420726563697069656e742063616e6e60448201527f6f74206265206164647265737328302900000000000000000000000000000000606482015260840161031d565b6105a58787338888888888610887565b60006107278261103e565b156107a1578173ffffffffffffffffffffffffffffffffffffffff1663c01e1bd66040518163ffffffff1660e01b8152600401602060405180830381865afa158015610777573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061079b91906116fe565b92915050565b6107aa8261106a565b156107fa578173ffffffffffffffffffffffffffffffffffffffff1663d6c0b2c46040518163ffffffff1660e01b8152600401602060405180830381865afa158015610777573d6000803e3d6000fd5b6040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603660248201527f4c324552433732314272696467653a206c6f63616c20746f6b656e20696e746560448201527f7266616365206973206e6f7420636f6d706c69616e7400000000000000000000606482015260840161031d565b919050565b73ffffffffffffffffffffffffffffffffffffffff871661092a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603160248201527f4c324552433732314272696467653a2072656d6f746520746f6b656e2063616e60448201527f6e6f742062652061646472657373283029000000000000000000000000000000606482015260840161031d565b6109338861071c565b73ffffffffffffffffffffffffffffffffffffffff168773ffffffffffffffffffffffffffffffffffffffff16146109ed576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603760248201527f4c324552433732314272696467653a2072656d6f746520746f6b656e20646f6560448201527f73206e6f74206d6174636820676976656e2076616c7565000000000000000000606482015260840161031d565b6040517f6352211e0000000000000000000000000000000000000000000000000000000081526004810185905273ffffffffffffffffffffffffffffffffffffffff891690636352211e90602401602060405180830381865afa158015610a58573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610a7c91906116fe565b73ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff1614610b36576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603e60248201527f4c324552433732314272696467653a205769746864726177616c206973206e6f60448201527f74206265696e6720696e69746961746564206279204e4654206f776e65720000606482015260840161031d565b610b41888786611096565b600063761f449360e01b888a8989898888604051602401610b689796959493929190611764565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fffffffff000000000000000000000000000000000000000000000000000000009094169390931790925290517f3dbb202b00000000000000000000000000000000000000000000000000000000815290915073ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001690633dbb202b90610c7d907f000000000000000000000000000000000000000000000000000000000000000090859089906004016117c1565b600060405180830381600087803b158015610c9757600080fd5b505af1158015610cab573d6000803e3d6000fd5b505050508673ffffffffffffffffffffffffffffffffffffffff168873ffffffffffffffffffffffffffffffffffffffff168a73ffffffffffffffffffffffffffffffffffffffff167fb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a589898888604051610d299493929190611806565b60405180910390a48673ffffffffffffffffffffffffffffffffffffffff168973ffffffffffffffffffffffffffffffffffffffff168973ffffffffffffffffffffffffffffffffffffffff167f73d170910aba9e6d50b102db522b1dbcd796216f5128b445aa2135272886497e89898888604051610dab9493929190611806565b60405180910390a4505050505050505050565b3073ffffffffffffffffffffffffffffffffffffffff881603610e63576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602a60248201527f4c324552433732314272696467653a206c6f63616c20746f6b656e2063616e6e60448201527f6f742062652073656c6600000000000000000000000000000000000000000000606482015260840161031d565b610e6c8761071c565b73ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff1614610f26576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603760248201527f4c324552433732314272696467653a2072656d6f746520746f6b656e20646f6560448201527f73206e6f74206d6174636820676976656e2076616c7565000000000000000000606482015260840161031d565b610f31878585611192565b8473ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff168873ffffffffffffffffffffffffffffffffffffffff167f1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac87878787604051610fab9493929190611806565b60405180910390a48473ffffffffffffffffffffffffffffffffffffffff168773ffffffffffffffffffffffffffffffffffffffff168773ffffffffffffffffffffffffffffffffffffffff167fb0444523268717a02698be47d0803aa7468c00acbed2f8bd93a0459cde61dd898787878760405161102d9493929190611806565b60405180910390a450505050505050565b600061079b827f1d1d8b6300000000000000000000000000000000000000000000000000000000611264565b600061079b827f74259ebf00000000000000000000000000000000000000000000000000000000611264565b61109f8361103e565b15611129576040517f9dc29fac00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff838116600483015260248201839052841690639dc29fac906044015b600060405180830381600087803b15801561111557600080fd5b505af11580156105a5573d6000803e3d6000fd5b6111328361106a565b156107fa576040517f9dc29fac00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff838116600483015260248201839052841690639dc29fac906044016110fb565b61119b8361103e565b156111fb576040517f40c10f1900000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff8381166004830152602482018390528416906340c10f19906044016110fb565b6112048361106a565b156107fa576040517fa144819400000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff83811660048301526024820183905284169063a1448194906044016110fb565b600061126f83611287565b8015611280575061128083836112eb565b9392505050565b60006112b3827f01ffc9a7000000000000000000000000000000000000000000000000000000006112eb565b801561079b57506112e4827fffffffff000000000000000000000000000000000000000000000000000000006112eb565b1592915050565b604080517fffffffff000000000000000000000000000000000000000000000000000000008316602480830191909152825180830390910181526044909101909152602080820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167f01ffc9a700000000000000000000000000000000000000000000000000000000178152825160009392849283928392918391908a617530fa92503d915060005190508280156113a3575060208210155b80156113af5750600081115b979650505050505050565b73ffffffffffffffffffffffffffffffffffffffff811681146113dc57600080fd5b50565b803563ffffffff8116811461088257600080fd5b60008083601f84011261140557600080fd5b50813567ffffffffffffffff81111561141d57600080fd5b60208301915083602082850101111561143557600080fd5b9250929050565b60008060008060006080868803121561145457600080fd5b853561145f816113ba565b945060208601359350611474604087016113df565b9250606086013567ffffffffffffffff81111561149057600080fd5b61149c888289016113f3565b969995985093965092949392505050565b60008060008060008060a087890312156114c657600080fd5b86356114d1816113ba565b955060208701356114e1816113ba565b9450604087013593506114f6606088016113df565b9250608087013567ffffffffffffffff81111561151257600080fd5b61151e89828a016113f3565b979a9699509497509295939492505050565b6000815180845260005b818110156115565760208185018101518683018201520161153a565b81811115611568576000602083870101525b50601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169290920160200192915050565b6020815260006112806020830184611530565b6000806000606084860312156115c357600080fd5b83356115ce816113ba565b925060208401356115de816113ba565b929592945050506040919091013590565b600080600080600080600060c0888a03121561160a57600080fd5b8735611615816113ba565b96506020880135611625816113ba565b95506040880135611635816113ba565b94506060880135611645816113ba565b93506080880135925060a088013567ffffffffffffffff81111561166857600080fd5b6116748a828b016113f3565b989b979a50959850939692959293505050565b600080600080600080600060c0888a0312156116a257600080fd5b87356116ad816113ba565b965060208801356116bd816113ba565b955060408801356116cd816113ba565b9450606088013593506116e2608089016113df565b925060a088013567ffffffffffffffff81111561166857600080fd5b60006020828403121561171057600080fd5b8151611280816113ba565b8183528181602085013750600060208284010152600060207fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f840116840101905092915050565b600073ffffffffffffffffffffffffffffffffffffffff808a1683528089166020840152808816604084015280871660608401525084608083015260c060a08301526117b460c08301848661171b565b9998505050505050505050565b73ffffffffffffffffffffffffffffffffffffffff841681526060602082015260006117f06060830185611530565b905063ffffffff83166040830152949350505050565b73ffffffffffffffffffffffffffffffffffffffff8516815283602082015260606040820152600061183c60608301848661171b565b969550505050505056fea164736f6c634300080f000a",
}

// OasysL2ERC721BridgeABI is the input ABI used to generate the binding from.
// Deprecated: Use OasysL2ERC721BridgeMetaData.ABI instead.
var OasysL2ERC721BridgeABI = OasysL2ERC721BridgeMetaData.ABI

// OasysL2ERC721BridgeBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use OasysL2ERC721BridgeMetaData.Bin instead.
var OasysL2ERC721BridgeBin = OasysL2ERC721BridgeMetaData.Bin

// DeployOasysL2ERC721Bridge deploys a new Ethereum contract, binding an instance of OasysL2ERC721Bridge to it.
func DeployOasysL2ERC721Bridge(auth *bind.TransactOpts, backend bind.ContractBackend, _messenger common.Address, _otherBridge common.Address) (common.Address, *types.Transaction, *OasysL2ERC721Bridge, error) {
	parsed, err := OasysL2ERC721BridgeMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(OasysL2ERC721BridgeBin), backend, _messenger, _otherBridge)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &OasysL2ERC721Bridge{OasysL2ERC721BridgeCaller: OasysL2ERC721BridgeCaller{contract: contract}, OasysL2ERC721BridgeTransactor: OasysL2ERC721BridgeTransactor{contract: contract}, OasysL2ERC721BridgeFilterer: OasysL2ERC721BridgeFilterer{contract: contract}}, nil
}

// OasysL2ERC721Bridge is an auto generated Go binding around an Ethereum contract.
type OasysL2ERC721Bridge struct {
	OasysL2ERC721BridgeCaller     // Read-only binding to the contract
	OasysL2ERC721BridgeTransactor // Write-only binding to the contract
	OasysL2ERC721BridgeFilterer   // Log filterer for contract events
}

// OasysL2ERC721BridgeCaller is an auto generated read-only Go binding around an Ethereum contract.
type OasysL2ERC721BridgeCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL2ERC721BridgeTransactor is an auto generated write-only Go binding around an Ethereum contract.
type OasysL2ERC721BridgeTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL2ERC721BridgeFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type OasysL2ERC721BridgeFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL2ERC721BridgeSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type OasysL2ERC721BridgeSession struct {
	Contract     *OasysL2ERC721Bridge // Generic contract binding to set the session for
	CallOpts     bind.CallOpts        // Call options to use throughout this session
	TransactOpts bind.TransactOpts    // Transaction auth options to use throughout this session
}

// OasysL2ERC721BridgeCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type OasysL2ERC721BridgeCallerSession struct {
	Contract *OasysL2ERC721BridgeCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts              // Call options to use throughout this session
}

// OasysL2ERC721BridgeTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type OasysL2ERC721BridgeTransactorSession struct {
	Contract     *OasysL2ERC721BridgeTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts              // Transaction auth options to use throughout this session
}

// OasysL2ERC721BridgeRaw is an auto generated low-level Go binding around an Ethereum contract.
type OasysL2ERC721BridgeRaw struct {
	Contract *OasysL2ERC721Bridge // Generic contract binding to access the raw methods on
}

// OasysL2ERC721BridgeCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type OasysL2ERC721BridgeCallerRaw struct {
	Contract *OasysL2ERC721BridgeCaller // Generic read-only contract binding to access the raw methods on
}

// OasysL2ERC721BridgeTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type OasysL2ERC721BridgeTransactorRaw struct {
	Contract *OasysL2ERC721BridgeTransactor // Generic write-only contract binding to access the raw methods on
}

// NewOasysL2ERC721Bridge creates a new instance of OasysL2ERC721Bridge, bound to a specific deployed contract.
func NewOasysL2ERC721Bridge(address common.Address, backend bind.ContractBackend) (*OasysL2ERC721Bridge, error) {
	contract, err := bindOasysL2ERC721Bridge(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721Bridge{OasysL2ERC721BridgeCaller: OasysL2ERC721BridgeCaller{contract: contract}, OasysL2ERC721BridgeTransactor: OasysL2ERC721BridgeTransactor{contract: contract}, OasysL2ERC721BridgeFilterer: OasysL2ERC721BridgeFilterer{contract: contract}}, nil
}

// NewOasysL2ERC721BridgeCaller creates a new read-only instance of OasysL2ERC721Bridge, bound to a specific deployed contract.
func NewOasysL2ERC721BridgeCaller(address common.Address, caller bind.ContractCaller) (*OasysL2ERC721BridgeCaller, error) {
	contract, err := bindOasysL2ERC721Bridge(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeCaller{contract: contract}, nil
}

// NewOasysL2ERC721BridgeTransactor creates a new write-only instance of OasysL2ERC721Bridge, bound to a specific deployed contract.
func NewOasysL2ERC721BridgeTransactor(address common.Address, transactor bind.ContractTransactor) (*OasysL2ERC721BridgeTransactor, error) {
	contract, err := bindOasysL2ERC721Bridge(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeTransactor{contract: contract}, nil
}

// NewOasysL2ERC721BridgeFilterer creates a new log filterer instance of OasysL2ERC721Bridge, bound to a specific deployed contract.
func NewOasysL2ERC721BridgeFilterer(address common.Address, filterer bind.ContractFilterer) (*OasysL2ERC721BridgeFilterer, error) {
	contract, err := bindOasysL2ERC721Bridge(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeFilterer{contract: contract}, nil
}

// bindOasysL2ERC721Bridge binds a generic wrapper to an already deployed contract.
func bindOasysL2ERC721Bridge(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(OasysL2ERC721BridgeABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _OasysL2ERC721Bridge.Contract.OasysL2ERC721BridgeCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.OasysL2ERC721BridgeTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.OasysL2ERC721BridgeTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _OasysL2ERC721Bridge.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.contract.Transact(opts, method, params...)
}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) MESSENGER(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "MESSENGER")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) MESSENGER() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.MESSENGER(&_OasysL2ERC721Bridge.CallOpts)
}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) MESSENGER() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.MESSENGER(&_OasysL2ERC721Bridge.CallOpts)
}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) OTHERBRIDGE(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "OTHER_BRIDGE")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) OTHERBRIDGE() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.OTHERBRIDGE(&_OasysL2ERC721Bridge.CallOpts)
}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) OTHERBRIDGE() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.OTHERBRIDGE(&_OasysL2ERC721Bridge.CallOpts)
}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) Deposits(opts *bind.CallOpts, arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "deposits", arg0, arg1, arg2)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) Deposits(arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	return _OasysL2ERC721Bridge.Contract.Deposits(&_OasysL2ERC721Bridge.CallOpts, arg0, arg1, arg2)
}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) Deposits(arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	return _OasysL2ERC721Bridge.Contract.Deposits(&_OasysL2ERC721Bridge.CallOpts, arg0, arg1, arg2)
}

// L1ERC721Bridge is a free data retrieval call binding the contract method 0xc4e8ddfa.
//
// Solidity: function l1ERC721Bridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) L1ERC721Bridge(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "l1ERC721Bridge")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// L1ERC721Bridge is a free data retrieval call binding the contract method 0xc4e8ddfa.
//
// Solidity: function l1ERC721Bridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) L1ERC721Bridge() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.L1ERC721Bridge(&_OasysL2ERC721Bridge.CallOpts)
}

// L1ERC721Bridge is a free data retrieval call binding the contract method 0xc4e8ddfa.
//
// Solidity: function l1ERC721Bridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) L1ERC721Bridge() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.L1ERC721Bridge(&_OasysL2ERC721Bridge.CallOpts)
}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) Messenger(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "messenger")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) Messenger() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.Messenger(&_OasysL2ERC721Bridge.CallOpts)
}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) Messenger() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.Messenger(&_OasysL2ERC721Bridge.CallOpts)
}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) OtherBridge(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "otherBridge")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) OtherBridge() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.OtherBridge(&_OasysL2ERC721Bridge.CallOpts)
}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) OtherBridge() (common.Address, error) {
	return _OasysL2ERC721Bridge.Contract.OtherBridge(&_OasysL2ERC721Bridge.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCaller) Version(opts *bind.CallOpts) (string, error) {
	var out []interface{}
	err := _OasysL2ERC721Bridge.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(string)).(*string)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) Version() (string, error) {
	return _OasysL2ERC721Bridge.Contract.Version(&_OasysL2ERC721Bridge.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeCallerSession) Version() (string, error) {
	return _OasysL2ERC721Bridge.Contract.Version(&_OasysL2ERC721Bridge.CallOpts)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) BridgeERC721(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "bridgeERC721", _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) BridgeERC721(_localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.BridgeERC721(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) BridgeERC721(_localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.BridgeERC721(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) BridgeERC721To(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "bridgeERC721To", _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) BridgeERC721To(_localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.BridgeERC721To(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) BridgeERC721To(_localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.BridgeERC721To(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) FinalizeBridgeERC721(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "finalizeBridgeERC721", _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) FinalizeBridgeERC721(_localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.FinalizeBridgeERC721(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) FinalizeBridgeERC721(_localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.FinalizeBridgeERC721(&_OasysL2ERC721Bridge.TransactOpts, _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeDeposit is a paid mutator transaction binding the contract method 0x662a633a.
//
// Solidity: function finalizeDeposit(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) FinalizeDeposit(opts *bind.TransactOpts, _l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "finalizeDeposit", _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// FinalizeDeposit is a paid mutator transaction binding the contract method 0x662a633a.
//
// Solidity: function finalizeDeposit(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) FinalizeDeposit(_l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.FinalizeDeposit(&_OasysL2ERC721Bridge.TransactOpts, _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// FinalizeDeposit is a paid mutator transaction binding the contract method 0x662a633a.
//
// Solidity: function finalizeDeposit(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) FinalizeDeposit(_l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.FinalizeDeposit(&_OasysL2ERC721Bridge.TransactOpts, _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// Withdraw is a paid mutator transaction binding the contract method 0x32b7006d.
//
// Solidity: function withdraw(address _l2Token, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) Withdraw(opts *bind.TransactOpts, _l2Token common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "withdraw", _l2Token, _tokenId, _l1Gas, _data)
}

// Withdraw is a paid mutator transaction binding the contract method 0x32b7006d.
//
// Solidity: function withdraw(address _l2Token, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) Withdraw(_l2Token common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.Withdraw(&_OasysL2ERC721Bridge.TransactOpts, _l2Token, _tokenId, _l1Gas, _data)
}

// Withdraw is a paid mutator transaction binding the contract method 0x32b7006d.
//
// Solidity: function withdraw(address _l2Token, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) Withdraw(_l2Token common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.Withdraw(&_OasysL2ERC721Bridge.TransactOpts, _l2Token, _tokenId, _l1Gas, _data)
}

// WithdrawTo is a paid mutator transaction binding the contract method 0xa3a79548.
//
// Solidity: function withdrawTo(address _l2Token, address _to, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactor) WithdrawTo(opts *bind.TransactOpts, _l2Token common.Address, _to common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.contract.Transact(opts, "withdrawTo", _l2Token, _to, _tokenId, _l1Gas, _data)
}

// WithdrawTo is a paid mutator transaction binding the contract method 0xa3a79548.
//
// Solidity: function withdrawTo(address _l2Token, address _to, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeSession) WithdrawTo(_l2Token common.Address, _to common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.WithdrawTo(&_OasysL2ERC721Bridge.TransactOpts, _l2Token, _to, _tokenId, _l1Gas, _data)
}

// WithdrawTo is a paid mutator transaction binding the contract method 0xa3a79548.
//
// Solidity: function withdrawTo(address _l2Token, address _to, uint256 _tokenId, uint32 _l1Gas, bytes _data) returns()
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeTransactorSession) WithdrawTo(_l2Token common.Address, _to common.Address, _tokenId *big.Int, _l1Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL2ERC721Bridge.Contract.WithdrawTo(&_OasysL2ERC721Bridge.TransactOpts, _l2Token, _to, _tokenId, _l1Gas, _data)
}

// OasysL2ERC721BridgeDepositFailedIterator is returned from FilterDepositFailed and is used to iterate over the raw logs and unpacked data for DepositFailed events raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeDepositFailedIterator struct {
	Event *OasysL2ERC721BridgeDepositFailed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *OasysL2ERC721BridgeDepositFailedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL2ERC721BridgeDepositFailed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(OasysL2ERC721BridgeDepositFailed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *OasysL2ERC721BridgeDepositFailedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL2ERC721BridgeDepositFailedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL2ERC721BridgeDepositFailed represents a DepositFailed event raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeDepositFailed struct {
	L1Token common.Address
	L2Token common.Address
	From    common.Address
	To      common.Address
	TokenId *big.Int
	Data    []byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterDepositFailed is a free log retrieval operation binding the contract event 0x7ea89a4591614515571c2b51f5ea06494056f261c10ab1ed8c03c7590d87bce0.
//
// Solidity: event DepositFailed(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) FilterDepositFailed(opts *bind.FilterOpts, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (*OasysL2ERC721BridgeDepositFailedIterator, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.FilterLogs(opts, "DepositFailed", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeDepositFailedIterator{contract: _OasysL2ERC721Bridge.contract, event: "DepositFailed", logs: logs, sub: sub}, nil
}

// WatchDepositFailed is a free log subscription operation binding the contract event 0x7ea89a4591614515571c2b51f5ea06494056f261c10ab1ed8c03c7590d87bce0.
//
// Solidity: event DepositFailed(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) WatchDepositFailed(opts *bind.WatchOpts, sink chan<- *OasysL2ERC721BridgeDepositFailed, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (event.Subscription, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.WatchLogs(opts, "DepositFailed", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL2ERC721BridgeDepositFailed)
				if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "DepositFailed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDepositFailed is a log parse operation binding the contract event 0x7ea89a4591614515571c2b51f5ea06494056f261c10ab1ed8c03c7590d87bce0.
//
// Solidity: event DepositFailed(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) ParseDepositFailed(log types.Log) (*OasysL2ERC721BridgeDepositFailed, error) {
	event := new(OasysL2ERC721BridgeDepositFailed)
	if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "DepositFailed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL2ERC721BridgeDepositFinalizedIterator is returned from FilterDepositFinalized and is used to iterate over the raw logs and unpacked data for DepositFinalized events raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeDepositFinalizedIterator struct {
	Event *OasysL2ERC721BridgeDepositFinalized // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *OasysL2ERC721BridgeDepositFinalizedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL2ERC721BridgeDepositFinalized)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(OasysL2ERC721BridgeDepositFinalized)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *OasysL2ERC721BridgeDepositFinalizedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL2ERC721BridgeDepositFinalizedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL2ERC721BridgeDepositFinalized represents a DepositFinalized event raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeDepositFinalized struct {
	L1Token common.Address
	L2Token common.Address
	From    common.Address
	To      common.Address
	TokenId *big.Int
	Data    []byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterDepositFinalized is a free log retrieval operation binding the contract event 0xb0444523268717a02698be47d0803aa7468c00acbed2f8bd93a0459cde61dd89.
//
// Solidity: event DepositFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) FilterDepositFinalized(opts *bind.FilterOpts, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (*OasysL2ERC721BridgeDepositFinalizedIterator, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.FilterLogs(opts, "DepositFinalized", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeDepositFinalizedIterator{contract: _OasysL2ERC721Bridge.contract, event: "DepositFinalized", logs: logs, sub: sub}, nil
}

// WatchDepositFinalized is a free log subscription operation binding the contract event 0xb0444523268717a02698be47d0803aa7468c00acbed2f8bd93a0459cde61dd89.
//
// Solidity: event DepositFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) WatchDepositFinalized(opts *bind.WatchOpts, sink chan<- *OasysL2ERC721BridgeDepositFinalized, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (event.Subscription, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.WatchLogs(opts, "DepositFinalized", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL2ERC721BridgeDepositFinalized)
				if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "DepositFinalized", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDepositFinalized is a log parse operation binding the contract event 0xb0444523268717a02698be47d0803aa7468c00acbed2f8bd93a0459cde61dd89.
//
// Solidity: event DepositFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) ParseDepositFinalized(log types.Log) (*OasysL2ERC721BridgeDepositFinalized, error) {
	event := new(OasysL2ERC721BridgeDepositFinalized)
	if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "DepositFinalized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL2ERC721BridgeERC721BridgeFinalizedIterator is returned from FilterERC721BridgeFinalized and is used to iterate over the raw logs and unpacked data for ERC721BridgeFinalized events raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeERC721BridgeFinalizedIterator struct {
	Event *OasysL2ERC721BridgeERC721BridgeFinalized // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *OasysL2ERC721BridgeERC721BridgeFinalizedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL2ERC721BridgeERC721BridgeFinalized)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(OasysL2ERC721BridgeERC721BridgeFinalized)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *OasysL2ERC721BridgeERC721BridgeFinalizedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL2ERC721BridgeERC721BridgeFinalizedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL2ERC721BridgeERC721BridgeFinalized represents a ERC721BridgeFinalized event raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeERC721BridgeFinalized struct {
	LocalToken  common.Address
	RemoteToken common.Address
	From        common.Address
	To          common.Address
	TokenId     *big.Int
	ExtraData   []byte
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterERC721BridgeFinalized is a free log retrieval operation binding the contract event 0x1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac.
//
// Solidity: event ERC721BridgeFinalized(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) FilterERC721BridgeFinalized(opts *bind.FilterOpts, localToken []common.Address, remoteToken []common.Address, from []common.Address) (*OasysL2ERC721BridgeERC721BridgeFinalizedIterator, error) {

	var localTokenRule []interface{}
	for _, localTokenItem := range localToken {
		localTokenRule = append(localTokenRule, localTokenItem)
	}
	var remoteTokenRule []interface{}
	for _, remoteTokenItem := range remoteToken {
		remoteTokenRule = append(remoteTokenRule, remoteTokenItem)
	}
	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.FilterLogs(opts, "ERC721BridgeFinalized", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeERC721BridgeFinalizedIterator{contract: _OasysL2ERC721Bridge.contract, event: "ERC721BridgeFinalized", logs: logs, sub: sub}, nil
}

// WatchERC721BridgeFinalized is a free log subscription operation binding the contract event 0x1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac.
//
// Solidity: event ERC721BridgeFinalized(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) WatchERC721BridgeFinalized(opts *bind.WatchOpts, sink chan<- *OasysL2ERC721BridgeERC721BridgeFinalized, localToken []common.Address, remoteToken []common.Address, from []common.Address) (event.Subscription, error) {

	var localTokenRule []interface{}
	for _, localTokenItem := range localToken {
		localTokenRule = append(localTokenRule, localTokenItem)
	}
	var remoteTokenRule []interface{}
	for _, remoteTokenItem := range remoteToken {
		remoteTokenRule = append(remoteTokenRule, remoteTokenItem)
	}
	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.WatchLogs(opts, "ERC721BridgeFinalized", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL2ERC721BridgeERC721BridgeFinalized)
				if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeFinalized", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseERC721BridgeFinalized is a log parse operation binding the contract event 0x1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac.
//
// Solidity: event ERC721BridgeFinalized(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) ParseERC721BridgeFinalized(log types.Log) (*OasysL2ERC721BridgeERC721BridgeFinalized, error) {
	event := new(OasysL2ERC721BridgeERC721BridgeFinalized)
	if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeFinalized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL2ERC721BridgeERC721BridgeInitiatedIterator is returned from FilterERC721BridgeInitiated and is used to iterate over the raw logs and unpacked data for ERC721BridgeInitiated events raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeERC721BridgeInitiatedIterator struct {
	Event *OasysL2ERC721BridgeERC721BridgeInitiated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *OasysL2ERC721BridgeERC721BridgeInitiatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL2ERC721BridgeERC721BridgeInitiated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(OasysL2ERC721BridgeERC721BridgeInitiated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *OasysL2ERC721BridgeERC721BridgeInitiatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL2ERC721BridgeERC721BridgeInitiatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL2ERC721BridgeERC721BridgeInitiated represents a ERC721BridgeInitiated event raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeERC721BridgeInitiated struct {
	LocalToken  common.Address
	RemoteToken common.Address
	From        common.Address
	To          common.Address
	TokenId     *big.Int
	ExtraData   []byte
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterERC721BridgeInitiated is a free log retrieval operation binding the contract event 0xb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a5.
//
// Solidity: event ERC721BridgeInitiated(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) FilterERC721BridgeInitiated(opts *bind.FilterOpts, localToken []common.Address, remoteToken []common.Address, from []common.Address) (*OasysL2ERC721BridgeERC721BridgeInitiatedIterator, error) {

	var localTokenRule []interface{}
	for _, localTokenItem := range localToken {
		localTokenRule = append(localTokenRule, localTokenItem)
	}
	var remoteTokenRule []interface{}
	for _, remoteTokenItem := range remoteToken {
		remoteTokenRule = append(remoteTokenRule, remoteTokenItem)
	}
	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.FilterLogs(opts, "ERC721BridgeInitiated", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeERC721BridgeInitiatedIterator{contract: _OasysL2ERC721Bridge.contract, event: "ERC721BridgeInitiated", logs: logs, sub: sub}, nil
}

// WatchERC721BridgeInitiated is a free log subscription operation binding the contract event 0xb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a5.
//
// Solidity: event ERC721BridgeInitiated(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) WatchERC721BridgeInitiated(opts *bind.WatchOpts, sink chan<- *OasysL2ERC721BridgeERC721BridgeInitiated, localToken []common.Address, remoteToken []common.Address, from []common.Address) (event.Subscription, error) {

	var localTokenRule []interface{}
	for _, localTokenItem := range localToken {
		localTokenRule = append(localTokenRule, localTokenItem)
	}
	var remoteTokenRule []interface{}
	for _, remoteTokenItem := range remoteToken {
		remoteTokenRule = append(remoteTokenRule, remoteTokenItem)
	}
	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.WatchLogs(opts, "ERC721BridgeInitiated", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL2ERC721BridgeERC721BridgeInitiated)
				if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeInitiated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseERC721BridgeInitiated is a log parse operation binding the contract event 0xb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a5.
//
// Solidity: event ERC721BridgeInitiated(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) ParseERC721BridgeInitiated(log types.Log) (*OasysL2ERC721BridgeERC721BridgeInitiated, error) {
	event := new(OasysL2ERC721BridgeERC721BridgeInitiated)
	if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeInitiated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL2ERC721BridgeWithdrawalInitiatedIterator is returned from FilterWithdrawalInitiated and is used to iterate over the raw logs and unpacked data for WithdrawalInitiated events raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeWithdrawalInitiatedIterator struct {
	Event *OasysL2ERC721BridgeWithdrawalInitiated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *OasysL2ERC721BridgeWithdrawalInitiatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL2ERC721BridgeWithdrawalInitiated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(OasysL2ERC721BridgeWithdrawalInitiated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *OasysL2ERC721BridgeWithdrawalInitiatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL2ERC721BridgeWithdrawalInitiatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL2ERC721BridgeWithdrawalInitiated represents a WithdrawalInitiated event raised by the OasysL2ERC721Bridge contract.
type OasysL2ERC721BridgeWithdrawalInitiated struct {
	L1Token common.Address
	L2Token common.Address
	From    common.Address
	To      common.Address
	TokenId *big.Int
	Data    []byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterWithdrawalInitiated is a free log retrieval operation binding the contract event 0x73d170910aba9e6d50b102db522b1dbcd796216f5128b445aa2135272886497e.
//
// Solidity: event WithdrawalInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) FilterWithdrawalInitiated(opts *bind.FilterOpts, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (*OasysL2ERC721BridgeWithdrawalInitiatedIterator, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.FilterLogs(opts, "WithdrawalInitiated", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL2ERC721BridgeWithdrawalInitiatedIterator{contract: _OasysL2ERC721Bridge.contract, event: "WithdrawalInitiated", logs: logs, sub: sub}, nil
}

// WatchWithdrawalInitiated is a free log subscription operation binding the contract event 0x73d170910aba9e6d50b102db522b1dbcd796216f5128b445aa2135272886497e.
//
// Solidity: event WithdrawalInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) WatchWithdrawalInitiated(opts *bind.WatchOpts, sink chan<- *OasysL2ERC721BridgeWithdrawalInitiated, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (event.Subscription, error) {

	var _l1TokenRule []interface{}
	for _, _l1TokenItem := range _l1Token {
		_l1TokenRule = append(_l1TokenRule, _l1TokenItem)
	}
	var _l2TokenRule []interface{}
	for _, _l2TokenItem := range _l2Token {
		_l2TokenRule = append(_l2TokenRule, _l2TokenItem)
	}
	var _fromRule []interface{}
	for _, _fromItem := range _from {
		_fromRule = append(_fromRule, _fromItem)
	}

	logs, sub, err := _OasysL2ERC721Bridge.contract.WatchLogs(opts, "WithdrawalInitiated", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL2ERC721BridgeWithdrawalInitiated)
				if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "WithdrawalInitiated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseWithdrawalInitiated is a log parse operation binding the contract event 0x73d170910aba9e6d50b102db522b1dbcd796216f5128b445aa2135272886497e.
//
// Solidity: event WithdrawalInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL2ERC721Bridge *OasysL2ERC721BridgeFilterer) ParseWithdrawalInitiated(log types.Log) (*OasysL2ERC721BridgeWithdrawalInitiated, error) {
	event := new(OasysL2ERC721BridgeWithdrawalInitiated)
	if err := _OasysL2ERC721Bridge.contract.UnpackLog(event, "WithdrawalInitiated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
