# @version ^0.3.7

struct Account:
    active: bool
    accountBalance: uint256

enum Status:
    Open
    Closed

accounts: HashMap[address, Account]

manager: address
status: Status

event ContractCreated:
    manager: address

event Deposit:
    account: address
    amount: uint256

event Withdraw:
    account: address
    amount: uint256

event Transfer:
    _from: address
    _to: address
    amount: uint256

event ContractTerminated:
    recipient: address
    amount: uint256

@external
def __init__():
    self.manager = msg.sender
    self.status = Status.Open

@external
@payable
def deposit():
    assert self.status == Status.Open, "bank is closed"
    account: Account = self.accounts[msg.sender]
    account.active = True
    account.accountBalance += msg.value
    self.accounts[msg.sender] = account
    log Deposit(msg.sender, msg.value)


@external
def withdraw(amount: uint256):
    assert self.status == Status.Open, "bank is closed"
    assert amount > 0, "amount is zero"
    assert self.accounts[msg.sender].accountBalance >= amount, "insufficient funds"
    assert(self.accounts[msg.sender].accountBalance <= self.balance)
    self.accounts[msg.sender].accountBalance -= amount
    send(msg.sender, amount)
    log Withdraw(msg.sender, amount)

@external
def transfer(dest: address, amount: uint256):
    assert self.status == Status.Open, "bank is closed"
    assert amount > 0, "amount is zero"
    assert self.accounts[dest].active, "inactive account"
    assert self.accounts[msg.sender].accountBalance > amount, "insufficient funds"
    self.accounts[dest].accountBalance += amount
    self.accounts[msg.sender].accountBalance -= amount
    log Transfer(msg.sender, dest, amount)

@view
@external
def getBalance(addr: address) -> uint256:
    return self.accounts[addr].accountBalance

@external
def close():
    assert msg.sender == self.manager, "only for managers"
    assert self.status == Status.Open, "bank is closed"
    self.status = Status.Closed
    log ContractTerminated(self.manager, self.balance)
    send(self.manager, self.balance)
