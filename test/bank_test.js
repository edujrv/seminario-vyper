const Bank = artifacts.require("bank");
// const truffleAssert = require("truffle-assertions");

contract("bank", (accounts) => {
  let bankInstance;

  before(async () => {
    bankInstance = await Bank.deployed();
  });

  

  it("should deposit funds", async () => {
    // Realizar una transacción de depósito
    await bankInstance.deposit({ value: web3.utils.toWei("1", "ether"), from: accounts[0] });

    // Obtener el saldo de la cuenta después del depósito
    const balance = await bankInstance.getBalance(accounts[0]);
    // Verificar el saldo de la cuenta
    assert.equal(balance.toString(), web3.utils.toWei("1", "ether"));
  });

  it("should emitir el evento Deposit al hacer un deposito. traducirpls", async () => {
    // Realizar una transacción de depósito
    let aux = await bankInstance.deposit({ value: web3.utils.toWei("1", "ether"), from: accounts[0] });

    // Obtener el saldo de la cuenta después del depósito
    const balance = await bankInstance.getBalance(accounts[0]);

    // event
    let eventLog = undefined;
    for (let log of aux.logs) {
        if (log.event == "Deposit") {
            eventLog = log;
            break;
        }
    }
    assert(eventLog != undefined, "No se emitio el evento Deposit");
  //  assert.equal(proposal, eventLog.args.proposal, "Evento con propuesta incorrecta");
    assert.equal(accounts[0], eventLog.args.account, "Evento con cuenta incorrecta");
    assert.equal(web3.utils.toWei("1", "ether"), eventLog.args.amount, "Evento con amount incorrecto");
  });

  it("shouldn't dejar retirar mas del balance de la cuenta", async () => {
    await bankInstance.deposit({ value: web3.utils.toWei("1", "ether"), from: accounts[1] });
    await verifyThrows(async () => {
        await bankInstance.withdraw(web3.utils.toWei("2", "ether"), {from: accounts[1]});
    }, /insufficient funds/);
  });
});

async function verifyThrows(pred, message) {
    let e;
    try {
        await pred();
    } catch (ex) {
        e = ex;
    }
    assert.throws(() => {
        if (e) { throw e; }
    }, message);
}
