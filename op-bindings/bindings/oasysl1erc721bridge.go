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

// OasysL1ERC721BridgeMetaData contains all meta data concerning the OasysL1ERC721Bridge contract.
var OasysL1ERC721BridgeMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"constructor\",\"inputs\":[{\"name\":\"_messenger\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_otherBridge\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"MESSENGER\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractCrossDomainMessenger\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"OTHER_BRIDGE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"bridgeERC721\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_minGasLimit\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"bridgeERC721To\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_minGasLimit\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"depositERC721\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_l2Gas\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"depositERC721To\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_l2Gas\",\"type\":\"uint32\",\"internalType\":\"uint32\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"deposits\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"finalizeBridgeERC721\",\"inputs\":[{\"name\":\"_localToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_remoteToken\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"finalizeERC721Withdrawal\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"l2ERC721Bridge\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"messenger\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractCrossDomainMessenger\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"otherBridge\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"version\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"string\",\"internalType\":\"string\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"ERC721BridgeFinalized\",\"inputs\":[{\"name\":\"localToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"remoteToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"extraData\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ERC721BridgeInitiated\",\"inputs\":[{\"name\":\"localToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"remoteToken\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"extraData\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ERC721DepositInitiated\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ERC721WithdrawalFinalized\",\"inputs\":[{\"name\":\"_l1Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_l2Token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_from\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"_to\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"_data\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false}]",
	Bin: "0x60c06040523480156200001157600080fd5b506040516200145238038062001452833981016040819052620000349162000153565b818181816001600160a01b038216620000a95760405162461bcd60e51b815260206004820152602c60248201527f4552433732314272696467653a206d657373656e6765722063616e6e6f74206260448201526b65206164647265737328302960a01b60648201526084015b60405180910390fd5b6001600160a01b038116620001195760405162461bcd60e51b815260206004820152602f60248201527f4552433732314272696467653a206f74686572206272696467652063616e6e6f60448201526e74206265206164647265737328302960881b6064820152608401620000a0565b6001600160a01b039182166080521660a052506200018b92505050565b80516001600160a01b03811681146200014e57600080fd5b919050565b600080604083850312156200016757600080fd5b620001728362000136565b9150620001826020840162000136565b90509250929050565b60805160a051611271620001e1600039600081816101ea0152818161026e015281816106980152610d5201526000818160fb015281816102240152818161066e015281816106cf0152610d2301526112716000f3fe608060405234801561001057600080fd5b50600436106100df5760003560e01c80637f46ddb21161008c578063aa55745211610066578063aa55745214610246578063c1bcfa4f14610259578063c89701a21461026c578063dbfc9c3f1461026c57600080fd5b80637f46ddb2146101e55780638f45e4771461020c578063927ede2d1461021f57600080fd5b806354fd4d50116100bd57806354fd4d50146101455780635d93a3fc1461018e578063761f4493146101d257600080fd5b806330389967146100e45780633687011a146100e45780633cb747bf146100f9575b600080fd5b6100f76100f2366004610ec4565b610292565b005b7f00000000000000000000000000000000000000000000000000000000000000005b60405173ffffffffffffffffffffffffffffffffffffffff90911681526020015b60405180910390f35b6101816040518060400160405280600581526020017f312e352e3000000000000000000000000000000000000000000000000000000081525081565b60405161013c9190610fb2565b6101c261019c366004610fcc565b600260209081526000938452604080852082529284528284209052825290205460ff1681565b604051901515815260200161013c565b6100f76101e036600461100d565b61033e565b61011b7f000000000000000000000000000000000000000000000000000000000000000081565b6100f761021a36600461100d565b6103d8565b61011b7f000000000000000000000000000000000000000000000000000000000000000081565b6100f76102543660046110a5565b61045b565b6100f76102673660046110a5565b610517565b7f000000000000000000000000000000000000000000000000000000000000000061011b565b333b15610326576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602d60248201527f4552433732314272696467653a206163636f756e74206973206e6f742065787460448201527f65726e616c6c79206f776e65640000000000000000000000000000000000000060648201526084015b60405180910390fd5b61033686863333888888886105ba565b505050505050565b61034d87878787878787610656565b8473ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff168873ffffffffffffffffffffffffffffffffffffffff167f7fb3671da6a9a3c4b54a15e06575a4fa57d6264ad848930a6ea490e03e7514c1878787876040516103c79493929190611165565b60405180910390a450505050505050565b6040517f761f4493000000000000000000000000000000000000000000000000000000008152309063761f449390610420908a908a908a908a908a908a908a906004016111a5565b600060405180830381600087803b15801561043a57600080fd5b505af115801561044e573d6000803e3d6000fd5b5050505050505050505050565b73ffffffffffffffffffffffffffffffffffffffff85166104fe576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603060248201527f4552433732314272696467653a206e667420726563697069656e742063616e6e60448201527f6f74206265206164647265737328302900000000000000000000000000000000606482015260840161031d565b61050e87873388888888886105ba565b50505050505050565b73ffffffffffffffffffffffffffffffffffffffff85166104fe576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603260248201527f4c314552433732314272696467653a206e667420726563697069656e7420636160448201527f6e6e6f7420626520616464726573732830290000000000000000000000000000606482015260840161031d565b6105ca8888888888888888610ac6565b8573ffffffffffffffffffffffffffffffffffffffff168773ffffffffffffffffffffffffffffffffffffffff168973ffffffffffffffffffffffffffffffffffffffff167fd660bea642cb3af692ff947912f15e82ec86ad0796523ba971c5f369a6f989c5888887876040516106449493929190611165565b60405180910390a45050505050505050565b3373ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001614801561077457507f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff167f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff16636e296e456040518163ffffffff1660e01b8152600401602060405180830381865afa158015610738573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061075c9190611202565b73ffffffffffffffffffffffffffffffffffffffff16145b610800576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603f60248201527f4552433732314272696467653a2066756e6374696f6e2063616e206f6e6c792060448201527f62652063616c6c65642066726f6d20746865206f746865722062726964676500606482015260840161031d565b3073ffffffffffffffffffffffffffffffffffffffff8816036108a5576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602a60248201527f4c314552433732314272696467653a206c6f63616c20746f6b656e2063616e6e60448201527f6f742062652073656c6600000000000000000000000000000000000000000000606482015260840161031d565b73ffffffffffffffffffffffffffffffffffffffff8088166000908152600260209081526040808320938a1683529281528282208683529052205460ff161515600114610974576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603960248201527f4c314552433732314272696467653a20546f6b656e204944206973206e6f742060448201527f657363726f77656420696e20746865204c312042726964676500000000000000606482015260840161031d565b73ffffffffffffffffffffffffffffffffffffffff87811660008181526002602090815260408083208b8616845282528083208884529091529081902080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00169055517f42842e0e000000000000000000000000000000000000000000000000000000008152306004820152918616602483015260448201859052906342842e0e90606401600060405180830381600087803b158015610a3457600080fd5b505af1158015610a48573d6000803e3d6000fd5b505050508473ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff168873ffffffffffffffffffffffffffffffffffffffff167f1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac878787876040516103c79493929190611165565b73ffffffffffffffffffffffffffffffffffffffff8716610b69576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603160248201527f4c314552433732314272696467653a2072656d6f746520746f6b656e2063616e60448201527f6e6f742062652061646472657373283029000000000000000000000000000000606482015260840161031d565b600063761f449360e01b888a8989898888604051602401610b9097969594939291906111a5565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0818403018152918152602080830180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fffffffff00000000000000000000000000000000000000000000000000000000959095169490941790935273ffffffffffffffffffffffffffffffffffffffff8c81166000818152600286528381208e8416825286528381208b82529095529382902080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0016600117905590517f23b872dd000000000000000000000000000000000000000000000000000000008152908a166004820152306024820152604481018890529092506323b872dd90606401600060405180830381600087803b158015610cd057600080fd5b505af1158015610ce4573d6000803e3d6000fd5b50506040517f3dbb202b00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169250633dbb202b9150610d7e907f0000000000000000000000000000000000000000000000000000000000000000908590899060040161121f565b600060405180830381600087803b158015610d9857600080fd5b505af1158015610dac573d6000803e3d6000fd5b505050508673ffffffffffffffffffffffffffffffffffffffff168873ffffffffffffffffffffffffffffffffffffffff168a73ffffffffffffffffffffffffffffffffffffffff167fb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a589898888604051610e2a9493929190611165565b60405180910390a4505050505050505050565b73ffffffffffffffffffffffffffffffffffffffff81168114610e5f57600080fd5b50565b803563ffffffff81168114610e7657600080fd5b919050565b60008083601f840112610e8d57600080fd5b50813567ffffffffffffffff811115610ea557600080fd5b602083019150836020828501011115610ebd57600080fd5b9250929050565b60008060008060008060a08789031215610edd57600080fd5b8635610ee881610e3d565b95506020870135610ef881610e3d565b945060408701359350610f0d60608801610e62565b9250608087013567ffffffffffffffff811115610f2957600080fd5b610f3589828a01610e7b565b979a9699509497509295939492505050565b6000815180845260005b81811015610f6d57602081850181015186830182015201610f51565b81811115610f7f576000602083870101525b50601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169290920160200192915050565b602081526000610fc56020830184610f47565b9392505050565b600080600060608486031215610fe157600080fd5b8335610fec81610e3d565b92506020840135610ffc81610e3d565b929592945050506040919091013590565b600080600080600080600060c0888a03121561102857600080fd5b873561103381610e3d565b9650602088013561104381610e3d565b9550604088013561105381610e3d565b9450606088013561106381610e3d565b93506080880135925060a088013567ffffffffffffffff81111561108657600080fd5b6110928a828b01610e7b565b989b979a50959850939692959293505050565b600080600080600080600060c0888a0312156110c057600080fd5b87356110cb81610e3d565b965060208801356110db81610e3d565b955060408801356110eb81610e3d565b94506060880135935061110060808901610e62565b925060a088013567ffffffffffffffff81111561108657600080fd5b8183528181602085013750600060208284010152600060207fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f840116840101905092915050565b73ffffffffffffffffffffffffffffffffffffffff8516815283602082015260606040820152600061119b60608301848661111c565b9695505050505050565b600073ffffffffffffffffffffffffffffffffffffffff808a1683528089166020840152808816604084015280871660608401525084608083015260c060a08301526111f560c08301848661111c565b9998505050505050505050565b60006020828403121561121457600080fd5b8151610fc581610e3d565b73ffffffffffffffffffffffffffffffffffffffff8416815260606020820152600061124e6060830185610f47565b905063ffffffff8316604083015294935050505056fea164736f6c634300080f000a",
}

// OasysL1ERC721BridgeABI is the input ABI used to generate the binding from.
// Deprecated: Use OasysL1ERC721BridgeMetaData.ABI instead.
var OasysL1ERC721BridgeABI = OasysL1ERC721BridgeMetaData.ABI

// OasysL1ERC721BridgeBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use OasysL1ERC721BridgeMetaData.Bin instead.
var OasysL1ERC721BridgeBin = OasysL1ERC721BridgeMetaData.Bin

// DeployOasysL1ERC721Bridge deploys a new Ethereum contract, binding an instance of OasysL1ERC721Bridge to it.
func DeployOasysL1ERC721Bridge(auth *bind.TransactOpts, backend bind.ContractBackend, _messenger common.Address, _otherBridge common.Address) (common.Address, *types.Transaction, *OasysL1ERC721Bridge, error) {
	parsed, err := OasysL1ERC721BridgeMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(OasysL1ERC721BridgeBin), backend, _messenger, _otherBridge)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &OasysL1ERC721Bridge{OasysL1ERC721BridgeCaller: OasysL1ERC721BridgeCaller{contract: contract}, OasysL1ERC721BridgeTransactor: OasysL1ERC721BridgeTransactor{contract: contract}, OasysL1ERC721BridgeFilterer: OasysL1ERC721BridgeFilterer{contract: contract}}, nil
}

// OasysL1ERC721Bridge is an auto generated Go binding around an Ethereum contract.
type OasysL1ERC721Bridge struct {
	OasysL1ERC721BridgeCaller     // Read-only binding to the contract
	OasysL1ERC721BridgeTransactor // Write-only binding to the contract
	OasysL1ERC721BridgeFilterer   // Log filterer for contract events
}

// OasysL1ERC721BridgeCaller is an auto generated read-only Go binding around an Ethereum contract.
type OasysL1ERC721BridgeCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL1ERC721BridgeTransactor is an auto generated write-only Go binding around an Ethereum contract.
type OasysL1ERC721BridgeTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL1ERC721BridgeFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type OasysL1ERC721BridgeFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// OasysL1ERC721BridgeSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type OasysL1ERC721BridgeSession struct {
	Contract     *OasysL1ERC721Bridge // Generic contract binding to set the session for
	CallOpts     bind.CallOpts        // Call options to use throughout this session
	TransactOpts bind.TransactOpts    // Transaction auth options to use throughout this session
}

// OasysL1ERC721BridgeCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type OasysL1ERC721BridgeCallerSession struct {
	Contract *OasysL1ERC721BridgeCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts              // Call options to use throughout this session
}

// OasysL1ERC721BridgeTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type OasysL1ERC721BridgeTransactorSession struct {
	Contract     *OasysL1ERC721BridgeTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts              // Transaction auth options to use throughout this session
}

// OasysL1ERC721BridgeRaw is an auto generated low-level Go binding around an Ethereum contract.
type OasysL1ERC721BridgeRaw struct {
	Contract *OasysL1ERC721Bridge // Generic contract binding to access the raw methods on
}

// OasysL1ERC721BridgeCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type OasysL1ERC721BridgeCallerRaw struct {
	Contract *OasysL1ERC721BridgeCaller // Generic read-only contract binding to access the raw methods on
}

// OasysL1ERC721BridgeTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type OasysL1ERC721BridgeTransactorRaw struct {
	Contract *OasysL1ERC721BridgeTransactor // Generic write-only contract binding to access the raw methods on
}

// NewOasysL1ERC721Bridge creates a new instance of OasysL1ERC721Bridge, bound to a specific deployed contract.
func NewOasysL1ERC721Bridge(address common.Address, backend bind.ContractBackend) (*OasysL1ERC721Bridge, error) {
	contract, err := bindOasysL1ERC721Bridge(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721Bridge{OasysL1ERC721BridgeCaller: OasysL1ERC721BridgeCaller{contract: contract}, OasysL1ERC721BridgeTransactor: OasysL1ERC721BridgeTransactor{contract: contract}, OasysL1ERC721BridgeFilterer: OasysL1ERC721BridgeFilterer{contract: contract}}, nil
}

// NewOasysL1ERC721BridgeCaller creates a new read-only instance of OasysL1ERC721Bridge, bound to a specific deployed contract.
func NewOasysL1ERC721BridgeCaller(address common.Address, caller bind.ContractCaller) (*OasysL1ERC721BridgeCaller, error) {
	contract, err := bindOasysL1ERC721Bridge(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeCaller{contract: contract}, nil
}

// NewOasysL1ERC721BridgeTransactor creates a new write-only instance of OasysL1ERC721Bridge, bound to a specific deployed contract.
func NewOasysL1ERC721BridgeTransactor(address common.Address, transactor bind.ContractTransactor) (*OasysL1ERC721BridgeTransactor, error) {
	contract, err := bindOasysL1ERC721Bridge(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeTransactor{contract: contract}, nil
}

// NewOasysL1ERC721BridgeFilterer creates a new log filterer instance of OasysL1ERC721Bridge, bound to a specific deployed contract.
func NewOasysL1ERC721BridgeFilterer(address common.Address, filterer bind.ContractFilterer) (*OasysL1ERC721BridgeFilterer, error) {
	contract, err := bindOasysL1ERC721Bridge(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeFilterer{contract: contract}, nil
}

// bindOasysL1ERC721Bridge binds a generic wrapper to an already deployed contract.
func bindOasysL1ERC721Bridge(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(OasysL1ERC721BridgeABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _OasysL1ERC721Bridge.Contract.OasysL1ERC721BridgeCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.OasysL1ERC721BridgeTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.OasysL1ERC721BridgeTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _OasysL1ERC721Bridge.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.contract.Transact(opts, method, params...)
}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) MESSENGER(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "MESSENGER")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) MESSENGER() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.MESSENGER(&_OasysL1ERC721Bridge.CallOpts)
}

// MESSENGER is a free data retrieval call binding the contract method 0x927ede2d.
//
// Solidity: function MESSENGER() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) MESSENGER() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.MESSENGER(&_OasysL1ERC721Bridge.CallOpts)
}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) OTHERBRIDGE(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "OTHER_BRIDGE")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) OTHERBRIDGE() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.OTHERBRIDGE(&_OasysL1ERC721Bridge.CallOpts)
}

// OTHERBRIDGE is a free data retrieval call binding the contract method 0x7f46ddb2.
//
// Solidity: function OTHER_BRIDGE() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) OTHERBRIDGE() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.OTHERBRIDGE(&_OasysL1ERC721Bridge.CallOpts)
}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) Deposits(opts *bind.CallOpts, arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "deposits", arg0, arg1, arg2)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) Deposits(arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	return _OasysL1ERC721Bridge.Contract.Deposits(&_OasysL1ERC721Bridge.CallOpts, arg0, arg1, arg2)
}

// Deposits is a free data retrieval call binding the contract method 0x5d93a3fc.
//
// Solidity: function deposits(address , address , uint256 ) view returns(bool)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) Deposits(arg0 common.Address, arg1 common.Address, arg2 *big.Int) (bool, error) {
	return _OasysL1ERC721Bridge.Contract.Deposits(&_OasysL1ERC721Bridge.CallOpts, arg0, arg1, arg2)
}

// L2ERC721Bridge is a free data retrieval call binding the contract method 0xdbfc9c3f.
//
// Solidity: function l2ERC721Bridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) L2ERC721Bridge(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "l2ERC721Bridge")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// L2ERC721Bridge is a free data retrieval call binding the contract method 0xdbfc9c3f.
//
// Solidity: function l2ERC721Bridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) L2ERC721Bridge() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.L2ERC721Bridge(&_OasysL1ERC721Bridge.CallOpts)
}

// L2ERC721Bridge is a free data retrieval call binding the contract method 0xdbfc9c3f.
//
// Solidity: function l2ERC721Bridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) L2ERC721Bridge() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.L2ERC721Bridge(&_OasysL1ERC721Bridge.CallOpts)
}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) Messenger(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "messenger")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) Messenger() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.Messenger(&_OasysL1ERC721Bridge.CallOpts)
}

// Messenger is a free data retrieval call binding the contract method 0x3cb747bf.
//
// Solidity: function messenger() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) Messenger() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.Messenger(&_OasysL1ERC721Bridge.CallOpts)
}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) OtherBridge(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "otherBridge")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) OtherBridge() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.OtherBridge(&_OasysL1ERC721Bridge.CallOpts)
}

// OtherBridge is a free data retrieval call binding the contract method 0xc89701a2.
//
// Solidity: function otherBridge() view returns(address)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) OtherBridge() (common.Address, error) {
	return _OasysL1ERC721Bridge.Contract.OtherBridge(&_OasysL1ERC721Bridge.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCaller) Version(opts *bind.CallOpts) (string, error) {
	var out []interface{}
	err := _OasysL1ERC721Bridge.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(string)).(*string)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) Version() (string, error) {
	return _OasysL1ERC721Bridge.Contract.Version(&_OasysL1ERC721Bridge.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(string)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeCallerSession) Version() (string, error) {
	return _OasysL1ERC721Bridge.Contract.Version(&_OasysL1ERC721Bridge.CallOpts)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) BridgeERC721(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "bridgeERC721", _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) BridgeERC721(_localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.BridgeERC721(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721 is a paid mutator transaction binding the contract method 0x3687011a.
//
// Solidity: function bridgeERC721(address _localToken, address _remoteToken, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) BridgeERC721(_localToken common.Address, _remoteToken common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.BridgeERC721(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) BridgeERC721To(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "bridgeERC721To", _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) BridgeERC721To(_localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.BridgeERC721To(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// BridgeERC721To is a paid mutator transaction binding the contract method 0xaa557452.
//
// Solidity: function bridgeERC721To(address _localToken, address _remoteToken, address _to, uint256 _tokenId, uint32 _minGasLimit, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) BridgeERC721To(_localToken common.Address, _remoteToken common.Address, _to common.Address, _tokenId *big.Int, _minGasLimit uint32, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.BridgeERC721To(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _to, _tokenId, _minGasLimit, _extraData)
}

// DepositERC721 is a paid mutator transaction binding the contract method 0x30389967.
//
// Solidity: function depositERC721(address _l1Token, address _l2Token, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) DepositERC721(opts *bind.TransactOpts, _l1Token common.Address, _l2Token common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "depositERC721", _l1Token, _l2Token, _tokenId, _l2Gas, _data)
}

// DepositERC721 is a paid mutator transaction binding the contract method 0x30389967.
//
// Solidity: function depositERC721(address _l1Token, address _l2Token, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) DepositERC721(_l1Token common.Address, _l2Token common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.DepositERC721(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _tokenId, _l2Gas, _data)
}

// DepositERC721 is a paid mutator transaction binding the contract method 0x30389967.
//
// Solidity: function depositERC721(address _l1Token, address _l2Token, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) DepositERC721(_l1Token common.Address, _l2Token common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.DepositERC721(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _tokenId, _l2Gas, _data)
}

// DepositERC721To is a paid mutator transaction binding the contract method 0xc1bcfa4f.
//
// Solidity: function depositERC721To(address _l1Token, address _l2Token, address _to, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) DepositERC721To(opts *bind.TransactOpts, _l1Token common.Address, _l2Token common.Address, _to common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "depositERC721To", _l1Token, _l2Token, _to, _tokenId, _l2Gas, _data)
}

// DepositERC721To is a paid mutator transaction binding the contract method 0xc1bcfa4f.
//
// Solidity: function depositERC721To(address _l1Token, address _l2Token, address _to, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) DepositERC721To(_l1Token common.Address, _l2Token common.Address, _to common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.DepositERC721To(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _to, _tokenId, _l2Gas, _data)
}

// DepositERC721To is a paid mutator transaction binding the contract method 0xc1bcfa4f.
//
// Solidity: function depositERC721To(address _l1Token, address _l2Token, address _to, uint256 _tokenId, uint32 _l2Gas, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) DepositERC721To(_l1Token common.Address, _l2Token common.Address, _to common.Address, _tokenId *big.Int, _l2Gas uint32, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.DepositERC721To(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _to, _tokenId, _l2Gas, _data)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) FinalizeBridgeERC721(opts *bind.TransactOpts, _localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "finalizeBridgeERC721", _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) FinalizeBridgeERC721(_localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.FinalizeBridgeERC721(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeBridgeERC721 is a paid mutator transaction binding the contract method 0x761f4493.
//
// Solidity: function finalizeBridgeERC721(address _localToken, address _remoteToken, address _from, address _to, uint256 _tokenId, bytes _extraData) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) FinalizeBridgeERC721(_localToken common.Address, _remoteToken common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _extraData []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.FinalizeBridgeERC721(&_OasysL1ERC721Bridge.TransactOpts, _localToken, _remoteToken, _from, _to, _tokenId, _extraData)
}

// FinalizeERC721Withdrawal is a paid mutator transaction binding the contract method 0x8f45e477.
//
// Solidity: function finalizeERC721Withdrawal(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactor) FinalizeERC721Withdrawal(opts *bind.TransactOpts, _l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.contract.Transact(opts, "finalizeERC721Withdrawal", _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// FinalizeERC721Withdrawal is a paid mutator transaction binding the contract method 0x8f45e477.
//
// Solidity: function finalizeERC721Withdrawal(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeSession) FinalizeERC721Withdrawal(_l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.FinalizeERC721Withdrawal(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// FinalizeERC721Withdrawal is a paid mutator transaction binding the contract method 0x8f45e477.
//
// Solidity: function finalizeERC721Withdrawal(address _l1Token, address _l2Token, address _from, address _to, uint256 _tokenId, bytes _data) returns()
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeTransactorSession) FinalizeERC721Withdrawal(_l1Token common.Address, _l2Token common.Address, _from common.Address, _to common.Address, _tokenId *big.Int, _data []byte) (*types.Transaction, error) {
	return _OasysL1ERC721Bridge.Contract.FinalizeERC721Withdrawal(&_OasysL1ERC721Bridge.TransactOpts, _l1Token, _l2Token, _from, _to, _tokenId, _data)
}

// OasysL1ERC721BridgeERC721BridgeFinalizedIterator is returned from FilterERC721BridgeFinalized and is used to iterate over the raw logs and unpacked data for ERC721BridgeFinalized events raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721BridgeFinalizedIterator struct {
	Event *OasysL1ERC721BridgeERC721BridgeFinalized // Event containing the contract specifics and raw log

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
func (it *OasysL1ERC721BridgeERC721BridgeFinalizedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL1ERC721BridgeERC721BridgeFinalized)
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
		it.Event = new(OasysL1ERC721BridgeERC721BridgeFinalized)
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
func (it *OasysL1ERC721BridgeERC721BridgeFinalizedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL1ERC721BridgeERC721BridgeFinalizedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL1ERC721BridgeERC721BridgeFinalized represents a ERC721BridgeFinalized event raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721BridgeFinalized struct {
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
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) FilterERC721BridgeFinalized(opts *bind.FilterOpts, localToken []common.Address, remoteToken []common.Address, from []common.Address) (*OasysL1ERC721BridgeERC721BridgeFinalizedIterator, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.FilterLogs(opts, "ERC721BridgeFinalized", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeERC721BridgeFinalizedIterator{contract: _OasysL1ERC721Bridge.contract, event: "ERC721BridgeFinalized", logs: logs, sub: sub}, nil
}

// WatchERC721BridgeFinalized is a free log subscription operation binding the contract event 0x1f39bf6707b5d608453e0ae4c067b562bcc4c85c0f562ef5d2c774d2e7f131ac.
//
// Solidity: event ERC721BridgeFinalized(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) WatchERC721BridgeFinalized(opts *bind.WatchOpts, sink chan<- *OasysL1ERC721BridgeERC721BridgeFinalized, localToken []common.Address, remoteToken []common.Address, from []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.WatchLogs(opts, "ERC721BridgeFinalized", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL1ERC721BridgeERC721BridgeFinalized)
				if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeFinalized", log); err != nil {
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
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) ParseERC721BridgeFinalized(log types.Log) (*OasysL1ERC721BridgeERC721BridgeFinalized, error) {
	event := new(OasysL1ERC721BridgeERC721BridgeFinalized)
	if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeFinalized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL1ERC721BridgeERC721BridgeInitiatedIterator is returned from FilterERC721BridgeInitiated and is used to iterate over the raw logs and unpacked data for ERC721BridgeInitiated events raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721BridgeInitiatedIterator struct {
	Event *OasysL1ERC721BridgeERC721BridgeInitiated // Event containing the contract specifics and raw log

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
func (it *OasysL1ERC721BridgeERC721BridgeInitiatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL1ERC721BridgeERC721BridgeInitiated)
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
		it.Event = new(OasysL1ERC721BridgeERC721BridgeInitiated)
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
func (it *OasysL1ERC721BridgeERC721BridgeInitiatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL1ERC721BridgeERC721BridgeInitiatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL1ERC721BridgeERC721BridgeInitiated represents a ERC721BridgeInitiated event raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721BridgeInitiated struct {
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
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) FilterERC721BridgeInitiated(opts *bind.FilterOpts, localToken []common.Address, remoteToken []common.Address, from []common.Address) (*OasysL1ERC721BridgeERC721BridgeInitiatedIterator, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.FilterLogs(opts, "ERC721BridgeInitiated", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeERC721BridgeInitiatedIterator{contract: _OasysL1ERC721Bridge.contract, event: "ERC721BridgeInitiated", logs: logs, sub: sub}, nil
}

// WatchERC721BridgeInitiated is a free log subscription operation binding the contract event 0xb7460e2a880f256ebef3406116ff3eee0cee51ebccdc2a40698f87ebb2e9c1a5.
//
// Solidity: event ERC721BridgeInitiated(address indexed localToken, address indexed remoteToken, address indexed from, address to, uint256 tokenId, bytes extraData)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) WatchERC721BridgeInitiated(opts *bind.WatchOpts, sink chan<- *OasysL1ERC721BridgeERC721BridgeInitiated, localToken []common.Address, remoteToken []common.Address, from []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.WatchLogs(opts, "ERC721BridgeInitiated", localTokenRule, remoteTokenRule, fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL1ERC721BridgeERC721BridgeInitiated)
				if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeInitiated", log); err != nil {
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
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) ParseERC721BridgeInitiated(log types.Log) (*OasysL1ERC721BridgeERC721BridgeInitiated, error) {
	event := new(OasysL1ERC721BridgeERC721BridgeInitiated)
	if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721BridgeInitiated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL1ERC721BridgeERC721DepositInitiatedIterator is returned from FilterERC721DepositInitiated and is used to iterate over the raw logs and unpacked data for ERC721DepositInitiated events raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721DepositInitiatedIterator struct {
	Event *OasysL1ERC721BridgeERC721DepositInitiated // Event containing the contract specifics and raw log

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
func (it *OasysL1ERC721BridgeERC721DepositInitiatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL1ERC721BridgeERC721DepositInitiated)
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
		it.Event = new(OasysL1ERC721BridgeERC721DepositInitiated)
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
func (it *OasysL1ERC721BridgeERC721DepositInitiatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL1ERC721BridgeERC721DepositInitiatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL1ERC721BridgeERC721DepositInitiated represents a ERC721DepositInitiated event raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721DepositInitiated struct {
	L1Token common.Address
	L2Token common.Address
	From    common.Address
	To      common.Address
	TokenId *big.Int
	Data    []byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterERC721DepositInitiated is a free log retrieval operation binding the contract event 0xd660bea642cb3af692ff947912f15e82ec86ad0796523ba971c5f369a6f989c5.
//
// Solidity: event ERC721DepositInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) FilterERC721DepositInitiated(opts *bind.FilterOpts, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (*OasysL1ERC721BridgeERC721DepositInitiatedIterator, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.FilterLogs(opts, "ERC721DepositInitiated", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeERC721DepositInitiatedIterator{contract: _OasysL1ERC721Bridge.contract, event: "ERC721DepositInitiated", logs: logs, sub: sub}, nil
}

// WatchERC721DepositInitiated is a free log subscription operation binding the contract event 0xd660bea642cb3af692ff947912f15e82ec86ad0796523ba971c5f369a6f989c5.
//
// Solidity: event ERC721DepositInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) WatchERC721DepositInitiated(opts *bind.WatchOpts, sink chan<- *OasysL1ERC721BridgeERC721DepositInitiated, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.WatchLogs(opts, "ERC721DepositInitiated", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL1ERC721BridgeERC721DepositInitiated)
				if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721DepositInitiated", log); err != nil {
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

// ParseERC721DepositInitiated is a log parse operation binding the contract event 0xd660bea642cb3af692ff947912f15e82ec86ad0796523ba971c5f369a6f989c5.
//
// Solidity: event ERC721DepositInitiated(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) ParseERC721DepositInitiated(log types.Log) (*OasysL1ERC721BridgeERC721DepositInitiated, error) {
	event := new(OasysL1ERC721BridgeERC721DepositInitiated)
	if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721DepositInitiated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator is returned from FilterERC721WithdrawalFinalized and is used to iterate over the raw logs and unpacked data for ERC721WithdrawalFinalized events raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator struct {
	Event *OasysL1ERC721BridgeERC721WithdrawalFinalized // Event containing the contract specifics and raw log

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
func (it *OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(OasysL1ERC721BridgeERC721WithdrawalFinalized)
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
		it.Event = new(OasysL1ERC721BridgeERC721WithdrawalFinalized)
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
func (it *OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// OasysL1ERC721BridgeERC721WithdrawalFinalized represents a ERC721WithdrawalFinalized event raised by the OasysL1ERC721Bridge contract.
type OasysL1ERC721BridgeERC721WithdrawalFinalized struct {
	L1Token common.Address
	L2Token common.Address
	From    common.Address
	To      common.Address
	TokenId *big.Int
	Data    []byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterERC721WithdrawalFinalized is a free log retrieval operation binding the contract event 0x7fb3671da6a9a3c4b54a15e06575a4fa57d6264ad848930a6ea490e03e7514c1.
//
// Solidity: event ERC721WithdrawalFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) FilterERC721WithdrawalFinalized(opts *bind.FilterOpts, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (*OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.FilterLogs(opts, "ERC721WithdrawalFinalized", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return &OasysL1ERC721BridgeERC721WithdrawalFinalizedIterator{contract: _OasysL1ERC721Bridge.contract, event: "ERC721WithdrawalFinalized", logs: logs, sub: sub}, nil
}

// WatchERC721WithdrawalFinalized is a free log subscription operation binding the contract event 0x7fb3671da6a9a3c4b54a15e06575a4fa57d6264ad848930a6ea490e03e7514c1.
//
// Solidity: event ERC721WithdrawalFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) WatchERC721WithdrawalFinalized(opts *bind.WatchOpts, sink chan<- *OasysL1ERC721BridgeERC721WithdrawalFinalized, _l1Token []common.Address, _l2Token []common.Address, _from []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _OasysL1ERC721Bridge.contract.WatchLogs(opts, "ERC721WithdrawalFinalized", _l1TokenRule, _l2TokenRule, _fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(OasysL1ERC721BridgeERC721WithdrawalFinalized)
				if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721WithdrawalFinalized", log); err != nil {
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

// ParseERC721WithdrawalFinalized is a log parse operation binding the contract event 0x7fb3671da6a9a3c4b54a15e06575a4fa57d6264ad848930a6ea490e03e7514c1.
//
// Solidity: event ERC721WithdrawalFinalized(address indexed _l1Token, address indexed _l2Token, address indexed _from, address _to, uint256 _tokenId, bytes _data)
func (_OasysL1ERC721Bridge *OasysL1ERC721BridgeFilterer) ParseERC721WithdrawalFinalized(log types.Log) (*OasysL1ERC721BridgeERC721WithdrawalFinalized, error) {
	event := new(OasysL1ERC721BridgeERC721WithdrawalFinalized)
	if err := _OasysL1ERC721Bridge.contract.UnpackLog(event, "ERC721WithdrawalFinalized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
