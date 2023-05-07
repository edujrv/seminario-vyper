# @version ^0.3.7

interface Bank:
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

@external
def __init__():
    self.client = msg.sender
    log ClientContractCreated(msg.sender)

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
