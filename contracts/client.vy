# @version ^0.3.7

interface Bank:
    # Events

    # event ContractCreated:
    #     manager: address
    # event Deposit:
    #     account: address
    #     amount: uint256
    # event Withdraw:
    #     account: address
    #     amount: uint256
    # event Transfer:
    #     _from: address
    #     _to: address
    #     amount: uint256
    # event ContractTerminated:
    #     recipient: address
    #     amount: uint256

    # Functions
    def deposit(): payable
    def withdraw(amount: uint256): nonpayable
    def transfer(dest: address, amount: uint256): nonpayable
    def getBalance(addr: address) -> uint256: nonpayable
    def close(): nonpayable


event ClientContractCreated: 
    Client: address

event ClientDeposit:
    bank: address
    amount: uint256

event ClientWithdraw: 
    bank: address
    amount: uint256

event ClientTransfer:
    bank: address
    _from: address
    _to: address
    amount: uint256

event ClientFundsReturned:
    recipient: address
    amount: uint256

event ClientTransferReceived:
    sender: address
    amount: uint256
    
client: address

@payable
@external
def deposit(addr: address):
    Bank(addr).deposit(value=msg.value)
    log ClientDeposit(addr, msg.value)

@external
def withdraw(addr: address, amount: uint256):
    assert msg.sender == self.client, "Only the client can execute this action"
    Bank(addr).withdraw(amount)
    log ClientWithdraw(addr, amount)

@external
def transfer(addr: address, to: address, amount: uint256):
    assert msg.sender == self.client, "Only the client can execute this action"
    Bank(addr).transfer(to, amount)
    log ClientTransfer(addr, self, to, amount)

@external
@payable
def __default__():
    log ClientTransferReceived(msg.sender, msg.value)

@external
def returnFunds():
    assert msg.sender == self.client, "Only the client can execute this action"
    log ClientFundsReturned(msg.sender, self.balance)
    send(msg.sender, self.balance)


# //SPDX-License-Identifier: UNLICENSED
# pragma solidity ^0.8.19;

# import "./Bank.sol";

# contract Client {
#     address external client;

#     event ClientContractCreated(address Client);
#     event ClientDeposit(address bank, uint amount);
#     event ClientWithdraw(address bank, uint amount);
#     event ClientTransfer(address bank, address from, address to, uint amount);
#     event ClientFundsReturned(address recipient, uint amount);
#     event ClientTransferReceived(address sender, uint amount);


#     modifier onlyClient() {
#         require(msg.sender == client, "only Client");
#         _;
#     }

#     constructor() {
#         client = msg.sender;
#         emit ClientContractCreated(msg.sender);
#     }

#     function deposit(address addr) external payable {
#         Bank(addr).deposit{value: msg.value}();
#         emit ClientDeposit(addr, msg.value);
#     }

#     function withdraw(address addr, uint amount) external onlyClient {
#         Bank(addr).withdraw(amount);
#         emit ClientWithdraw(addr, amount);
#     }

#     function transfer(address addr, address to, uint amount) external onlyClient{
#         Bank(addr).transfer(to,amount);
#         emit ClientTransfer(addr, address(this), to, amount);
#     }

#     receive() external payable {
#         emit ClientTransferReceived(msg.sender, msg.value);
#     }

#     function returnFunds() external onlyClient {
#         emit ClientFundsReturned(msg.sender, address(this).balance);
#         payable(msg.sender).transfer(address(this).balance);
#     }
# }