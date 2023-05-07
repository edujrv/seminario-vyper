const Bank = artifacts.require("bank");
const Client = artifacts.require("client");

var cliente
  before(async () => {
    clientInstance = await Client.deployed();
    bankInstance = await Bank.deployed();

  });

  contract("client", (accounts) => {
    it("should deposit funds en la cuenta del cliente", async () => {
        const amount =  web3.utils.toWei("1", "ether");
        await clientInstance.deposit(Bank.address, {value: amount});
        const balance = await bankInstance.getBalance(clientInstance.address);
        assert.equal(balance.toString(), web3.utils.toWei("1", "ether"));
        });

    it("should withdraw money form client account", async () => {
        const initialBalance = await bankInstance.getBalance(clientInstance.address);
        const amount =  web3.utils.toWei("1", "ether");
        await clientInstance.deposit(Bank.address, {value: amount});
        await clientInstance.withdraw(Bank.address, amount);
        const finalBalance = await bankInstance.getBalance(clientInstance.address);
        assert.equal(initialBalance.toString(), finalBalance.toString());
        });

    it("should transfer money to a client account", async () => {
        const amount =  web3.utils.toWei("1", "ether");
        await clientInstance.deposit(Bank.address, {value: amount});
        await bankInstance.deposit({ value: web3.utils.toWei("1", "ether"), from: accounts[1] });

        
        const initialBalance1 = await bankInstance.getBalance(clientInstance.address);
        const initialBalance2 = await bankInstance.getBalance(accounts[1]);

        await clientInstance.transfer(Bank.address, accounts[1], amount);

        const finalBalance1 = await bankInstance.getBalance(clientInstance.address);
        const finalBalance2 = await bankInstance.getBalance(accounts[1]);
      
        let balance1 = parseInt(initialBalance1) - parseInt(amount);
        let balance2 = parseInt(initialBalance2) + parseInt(amount);
        assert.equal(finalBalance2.toString(), balance2.toString());
        assert.equal(finalBalance1.toString(), balance1.toString());
        });
});