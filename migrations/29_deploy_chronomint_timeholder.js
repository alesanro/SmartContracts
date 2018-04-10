const TimeHolder = artifacts.require("./TimeHolder.sol");
const Storage = artifacts.require('./Storage.sol');
const StorageManager = artifacts.require('./StorageManager.sol');
const ContractsManager = artifacts.require("./ContractsManager.sol");
const MultiEventsHistory = artifacts.require("./MultiEventsHistory.sol");
const ERC20Manager = artifacts.require("./ERC20Manager.sol");
const TimeHolderWallet = artifacts.require('./TimeHolderWallet.sol')
const ChronoBankAssetProxy = artifacts.require('./ChronoBankAssetProxy.sol')
const ERC20DepositStorage = artifacts.require('./ERC20DepositStorage.sol')

module.exports = function(deployer, network, accounts) {
    // Wallet deployment
    deployer.deploy(TimeHolderWallet, Storage.address, "TimeHolderWallet")
    .then(() => StorageManager.deployed())
    .then((_storageManager) => _storageManager.giveAccess(TimeHolderWallet.address, 'Deposits'))
    .then(() => TimeHolderWallet.deployed())
    .then(_wallet => timeHolderWallet = _wallet)
    .then(() => timeHolderWallet.init(ContractsManager.address))

    .then(() => deployer.deploy(ERC20DepositStorage, Storage.address, "Deposits"))
    .then(() => StorageManager.deployed())
    .then((_storageManager) => _storageManager.giveAccess(ERC20DepositStorage.address, 'Deposits'))
    .then(() => ERC20DepositStorage.deployed())
    .then((erc20DepositStorage) => erc20DepositStorage.init(ContractsManager.address))
    // .then(() => MultiEventsHistory.deployed())
    // .then(_history => _history.authorize(ERC20DepositStorage.address))

    // TimeHolder deployment
    .then(() => deployer.deploy(TimeHolder,Storage.address,'Deposits'))
    .then(() => StorageManager.deployed())
    .then((_storageManager) => _storageManager.giveAccess(TimeHolder.address, 'Deposits'))
    .then(() => TimeHolder.deployed())
    .then(_timeHolder => _timeHolder.init(ContractsManager.address, ChronoBankAssetProxy.address, timeHolderWallet.address, accounts[0], ERC20DepositStorage.address))
    .then(() => MultiEventsHistory.deployed())
    .then(_history => _history.authorize(TimeHolder.address))
    .then(() => {
        if (network == "main") {
            return timeHolder.setLimit(100000000);
        }
    })
    .then(() => console.log("[MIGRATION] [29] TimeHolder: #done"))
}
