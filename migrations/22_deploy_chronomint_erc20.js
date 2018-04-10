var ERC20Manager = artifacts.require("./ERC20Manager.sol");
const Storage = artifacts.require('./Storage.sol');
const StorageManager = artifacts.require("./StorageManager.sol");
const ContractsManager = artifacts.require("./ContractsManager.sol");
const MultiEventsHistory = artifacts.require("./MultiEventsHistory.sol");

module.exports = function(deployer, network) {
    deployer.deploy(ERC20Manager, Storage.address, "ERC20Manager")
      .then(() => StorageManager.deployed())
      .then(_storageManager => _storageManager.giveAccess(ERC20Manager.address, "ERC20Manager"))
      .then(() => ERC20Manager.deployed())
      .then(_manager => manager = _manager)
      .then(() => manager.init(ContractsManager.address))
      .then(() => MultiEventsHistory.deployed())
      .then(_history => history = _history)
      .then(() => history.authorize(manager.address))
      .then(() => manager.setEventsHistory(history.address))
      .then(() => console.log("[MIGRATION] [22] ERC20Manager: #done"))
}
