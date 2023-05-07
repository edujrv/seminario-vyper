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

@external
@payable
def deposit():
    assert self.status == Status.Open, "bank is closed"
    account: Account = self.accounts[msg.sender]
    account.active = True
    account.accountBalance += msg.value
    log Deposit(msg.sender, msg.value)


@external
def withdraw(amount: uint256):
    assert self.status == Status.Open, "bank is closed"
    assert amount > 0, "amount is zero"
    assert self.accounts[msg.sender].accountBalance < amount, "insufficient funds"
    assert(self.accounts[msg.sender].accountBalance <= self.balance)
    self.accounts[msg.sender].accountBalance -= amount
    send(msg.sender, amount)
    log Withdraw(msg.sender, amount)

@external
def transfer(dest: address, amount: uint256):
    assert self.status == Status.Open, "bank is closed"
    assert amount > 0, "amount is zero"
    assert self.accounts[dest].active, "inactive account"
    assert self.accounts[msg.sender].accountBalance < amount, "insufficient funds"
    self.accounts[dest].accountBalance += amount
    self.accounts[msg.sender].accountBalance -= amount
    log Transfer(msg.sender, dest, amount)

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




# //SPDX-License-Identifier: UNLICENSED
# pragma solidity >=0.8.19;

# contract Bank {
#     struct Account {
#         bool active;
#         uint balance;
#     }

#     enum Status {
#         Open,
#         Closed
#     }

#     mapping(address => Account) external accounts;
#     address external manager;
#     Status external status;

#     event ContractCreated(address manager);
#     event Deposit(address account, uint amount);
#     event Withdraw(address account, uint amount);
#     event Transfer(address from, address to, uint amount);
#     event ContractTerminated(address recipient, uint amount);

#     error InsufficientFunds(uint requested, uint available);

#     modifier onlyManager() {
#         require(msg.sender == manager, "only for managers");
#         _;
#     }

#     modifier enoughFunds(uint amount) {
#         if (accounts[msg.sender].balance < amount)
#             revert InsufficientFunds({
#                 requested: amount,
#                 available: accounts[msg.sender].balance
#             });
#         _;
#     }

#     modifier activeAccount(address account) {
#         require(accounts[account].active, "inactive account");
#         _;
#     }

#     modifier nonZero(uint amount) {
#         require(amount > 0, "amount is zero");
#         _;
#     }

#     modifier bankIsOpen() {
#         require(status == Status.Open, "bank is closed");
#         _;
#     }

#     constructor() {
#         manager = msg.sender;
#         emit ContractCreated(manager);
#     }

#     function deposit() external payable bankIsOpen {
#         Account storage account = accounts[msg.sender];
#         account.active = true;
#         account.balance += msg.value;
#         emit Deposit(msg.sender, msg.value);
#     }

#     function withdraw(
#         uint amount
#     ) external bankIsOpen enoughFunds(amount) nonZero(amount) {
#         assert(accounts[msg.sender].balance <= address(this).balance);
#         accounts[msg.sender].balance -= amount;
#         payable(msg.sender).transfer(amount);
#         emit Withdraw(msg.sender, amount);
#     }

#     function transfer(
#         address dest,
#         uint amount
#     )
#         external
#         bankIsOpen
#         enoughFunds(amount)
#         activeAccount(dest)
#         nonZero(amount)
#     {
#         accounts[dest].balance += amount;
#         accounts[msg.sender].balance -= amount;
#         emit Transfer(msg.sender, dest, amount);
#     }

#     function balance(address addr) external view returns (uint) {
#         return accounts[addr].balance;
#     }

#     function close() external bankIsOpen onlyManager {
#         status = Status.Closed;
#         emit ContractTerminated(manager, address(this).balance);
#         payable(manager).transfer(address(this).balance);
#     }
# }