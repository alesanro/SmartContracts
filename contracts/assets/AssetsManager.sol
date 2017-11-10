pragma solidity ^0.4.11;

import "../core/common/BaseManager.sol";
import "../core/common/Once.sol";
import "../core/erc20/ERC20ManagerInterface.sol";
import "../core/platform/ChronoBankAssetProxyInterface.sol";
import "../core/platform/ChronoBankAssetOwnershipManager.sol";
import "../core/platform/ChronoBankPlatformInterface.sol";
import "../core/platform/ChronoBankPlatform.sol";
import "./TokenManagementInterface.sol";
import "./AssetsManagerInterface.sol";
import "./AssetsManagerEmitter.sol";
import "./PlatformsManagerInterface.sol";
import "../core/lib/AssetsManagerAggregations.sol";

contract OwnedContract {
    address public contractOwner;
}


contract TokenExtensionsFactory {
    function createTokenExtension(address _platform) returns (address);
}


contract EventsHistory {
    function authorize(address _eventEmitter) returns (bool);
    function reject(address _eventEmitter);
}


/**
* @title AssetsManager is a helper contract which allows centralized access to tokens' management
* on top of chronobank platforms. It is used in pair with PlatformsManager and provides
* a creation of token extensions for platforms.
* Contract also has methods for quick access to token info such as:
* - token address by symbol,
* - if token exists in a system,
* - if a user is a owner of a token.
*
* @dev This contract contains statistics getters but they are deprecated and will be removed soon.
*
*/
contract AssetsManager is AssetsManagerInterface, TokenExtensionRegistry, AssetOwningListener, BaseManager, AssetsManagerEmitter {

    /** Error codes */

    uint constant ERROR_ASSETS_MANAGER_SYMBOL_ALREADY_EXISTS = 30001;
    uint constant ERROR_ASSETS_MANAGER_INVALID_INVOCATION = 30002;
    uint constant ERROR_ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS = 30003;

    /** Storage keys */

    /** @dev address of a token extension factory contract  */
    StorageInterface.Address tokenExtensionFactory;

    /** @dev address of a token and proxy factory contract */
    StorageInterface.Address tokenFactory;

    /** @dev mapping (address => address) stands for (platform => tokenExtension) */
    StorageInterface.AddressAddressMapping platformToExtension;

    /** @dev collection of addresses of token extensions registered in AssetsManager */
    StorageInterface.OrderedAddressesSet tokenExtensions;

    /** @dev mapping (address => set(address)) stands for (user => set(platform)) */
    StorageInterface.AddressesSetMapping userToParticipatedPlatforms;

    /** @dev mapping (bytes32 => set(bytes32)) stands for (hash(user,platform) => set(tokenSymbol)) */
    StorageInterface.Bytes32SetMapping userWithPlatformToOwnedSymbols;

    /** @dev mapping (bytes32 => set(address)) stands for (hash(tokenSymbol,platform) => set(user)) */
    StorageInterface.AddressesSetMapping symbolWithPlatformToUsers;

    /**
    * @dev Guards methods for callers that are owners of a platform
    */
    modifier onlyPlatformOwner(address _platform) {
        if (OwnedContract(_platform).contractOwner() == msg.sender) {
            _;
        }
    }

    /**
    * @dev Guards methods where caller is AssetOwnershipResolver
    */
    modifier onlyResolver {
        if (lookupManager("AssetOwnershipResolver") == msg.sender) {
            _;
        }
    }

    /**
    * Constructor function
    *
    * @param _store link to a global storage
    * @param _crate namespace in a storage
    */
    function AssetsManager(Storage _store, bytes32 _crate) BaseManager(_store, _crate) {
        tokenExtensionFactory.init("tokenExtensionFactory");
        tokenFactory.init("tokenFactory");
        platformToExtension.init("v1platformToExtension");
        tokenExtensions.init("v1tokenExtensions");
        userToParticipatedPlatforms.init("v1userToParticipatedPlatforms");
        userWithPlatformToOwnedSymbols.init("v1userWithPlatformToOwnedSymbols");
        symbolWithPlatformToUsers.init("v1symbolWithPlatformToUsers");
    }

    /**
    * @dev Initalizer. Used by contract owner to initialize and re-initialize contract after deploying new versions
    * of related dependencies.
    *
    * @param _contractsManager contracts manager
    * @param _tokenExtensionFactory token extension factory address
    * @param _tokenFactory token and proxy factory address
    *
    * @return result code of an operation. `OK` if all went well
    */
    function init(address _contractsManager, address _tokenExtensionFactory, address _tokenFactory) onlyContractOwner public returns (uint) {
        BaseManager.init(_contractsManager, "AssetsManager");
        setTokenExtensionFactory(_tokenExtensionFactory);
        setTokenFactory(_tokenFactory);

        return OK;
    }

    /**
    * @dev Gets an address of currenty used token extension factory
    *
    * @return address of a factory
    */
    function getTokenExtensionFactory() public constant returns (address) {
        return store.get(tokenExtensionFactory);
    }

    /**
    * @dev Sets a new address of token extension factory contract as currently used in AssetsManager
    *
    * @param _tokenExtensionFactory address of an updated token extension factory contract
    *
    * @return result code of an operation. `OK` if all went well
    */
    function setTokenExtensionFactory(address _tokenExtensionFactory) onlyContractOwner public returns (uint) {
        require(_tokenExtensionFactory != 0x0);

        store.set(tokenExtensionFactory, _tokenExtensionFactory);
        return OK;
    }

    /**
    * @dev Gets an address of currenty used token and proxy factory
    *
    * @return address of a factory
    */
    function getTokenFactory() public constant returns (address) {
        return store.get(tokenFactory);
    }

    /**
    * @dev Sets a new address of token and proxy factory contract as currently used in AssetsManager
    *
    * @param _tokenFactory address of an updated token and proxy factory contract
    *
    * @return result code of an operation. `OK` if all went well
    */
    function setTokenFactory(address _tokenFactory) onlyContractOwner public returns (uint) {
        require(_tokenFactory != 0x0);

        store.set(tokenFactory, _tokenFactory);
        return OK;
    }

    /**
    * @dev Checks if a provided token extension address is a part of the system
    *
    * @param _tokenExtension address of a token extension
    *
    * @return `true` if a token extension is inside AssetsManager, `false` otherwise
    */
    function containsTokenExtension(address _tokenExtension) public constant returns (bool) {
        return store.includes(tokenExtensions, _tokenExtension);
    }

    /**
    * @dev Implements AssetOwningListener interface to provide an ability to track asset ownership
    * from chronobank platforms.
    * Should be called when new owner of a symbol is added in a platform.
    * Allowed to be invoked only by AssetOwnershipResolver.
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _symbol token's associated symbol
    * @param _platform address of a platform where asset's ownership had changed
    * @param _owner user which was added as an owner of the token
    */
    function assetOwnerAdded(bytes32 _symbol, address _platform, address _owner) onlyResolver public {
        bytes32 _symbolKey = keccak256(_owner, _platform);
        if (store.includes(userWithPlatformToOwnedSymbols, _symbolKey, _symbol)) {
            return;
        }

        store.add(userToParticipatedPlatforms, bytes32(_owner), _platform);
        store.add(userWithPlatformToOwnedSymbols, _symbolKey, _symbol);
        store.add(symbolWithPlatformToUsers, keccak256(_symbol, _platform), _owner);
    }

    /**
    * @dev Implements AssetOwningListener interface to provide an ability to track asset ownership
    * from chronobank platforms.
    * Should be called when an existed owner of a symbol is removed in a platform.
    * Allowed to be invoked only by AssetOwnershipResolver.
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _symbol token's associated symbol
    * @param _platform address of a platform where asset's ownership had changed
    * @param _owner user which was removed from the token's ownership
    */
    function assetOwnerRemoved(bytes32 _symbol, address _platform, address _owner) onlyResolver public {
        bytes32 _symbolKey = keccak256(_owner, _platform);
        if (!store.includes(userWithPlatformToOwnedSymbols, _symbolKey, _symbol)) {
            return;
        }

        store.remove(userWithPlatformToOwnedSymbols, _symbolKey, _symbol);

        if (store.count(userWithPlatformToOwnedSymbols, _symbolKey) == 0) {
            store.remove(userToParticipatedPlatforms, bytes32(_owner), _platform);
        }
        store.remove(symbolWithPlatformToUsers, keccak256(_symbol, _platform), _owner);
    }

    /**
    * @dev Registers and stores token extension of a platform into the system. Mostly this method should be used
    * when platform's token extention was removed manually from AssetsManager or there was no token extension at all.
    * It is preferred to create token extension by calling requestTokenExtension: this will ensure that the latest
    * version of token extension contract will be used.
    * There might be ONLY ONE token extension at a time associated with a platform and be registered in the system.
    * Can be used only by platform's owner associated with this token extension.
    *
    * @param _tokenExtension address of token extension
    *
    * @return result code of an operation. ERROR_ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS, ERROR_ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS
    *           might be returned.
    */
    function registerTokenExtension(address _tokenExtension) onlyPlatformOwner(TokenManagementInterface(_tokenExtension).platform()) public returns (uint) {
        if (store.includes(tokenExtensions, _tokenExtension)) {
            return _emitError(ERROR_ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS);
        }

        address _platform = TokenManagementInterface(_tokenExtension).platform();
        if (store.get(platformToExtension, _platform) != 0x0) {
            return _emitError(ERROR_ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS);
        }

        _setupTokenExtension(_platform, _tokenExtension);
        _emitTokenExtensionRegistered(_platform, _tokenExtension);
        return OK;
    }

    /**
    * @dev Unregisters and removes token extension from the system. It should be used when you know what are you doing,
    * because it will remove record of token extension for a platform and to continue using an associated token extension
    * with platform you should register a new token extension address or request a brand new one (see `requestTokenExtension` method).
    * Can be used only by platform's owner associated with this token extension.
    *
    * @param _tokenExtension address of a token extension
    *
    * @return result code of an operation. ERROR_ASSETS_MANAGER_INVALID_INVOCATION might be returned.
    */
    function unregisterTokenExtension(address _tokenExtension) onlyPlatformOwner(TokenManagementInterface(_tokenExtension).platform()) public returns (uint) {
        if (!store.includes(tokenExtensions, _tokenExtension)) {
            return _emitError(ERROR_ASSETS_MANAGER_INVALID_INVOCATION);
        }

        store.remove(tokenExtensions, _tokenExtension);
        store.set(platformToExtension, TokenManagementInterface(_tokenExtension).platform(), 0x0);
        EventsHistory(getEventsHistory()).reject(_tokenExtension);

        _emitTokenExtensionUnregistered(_tokenExtension);
        return OK;
    }

    /**
    * @dev Provides a way to "request" (meant check if a token extension exists for a passed platform and if it doesn't then
    * create a new one).
    *
    * @param _platform address of a platform for which token extension is requested
    *
    * @return result code of an operation.
    */
    function requestTokenExtension(address _platform) public returns (uint) {
        address _tokenExtension = getTokenExtension(_platform);
        if (_tokenExtension != 0x0) {
            _emitTokenExtensionRequested(_platform, _tokenExtension);
            return OK;
        }

        TokenExtensionsFactory _extensionsFactory = TokenExtensionsFactory(store.get(tokenExtensionFactory));
        _tokenExtension = _extensionsFactory.createTokenExtension(_platform);
        _setupTokenExtension(_platform, _tokenExtension);

        _emitTokenExtensionRequested(_platform, _tokenExtension);
        return OK;
    }

    /**
    * @dev Gets an associated token extension address with provided platform. If no token extension was found
    * then return 0x0.
    *
    * @param _platform platform address for associated token extension
    *
    * @return address of found token extension
    */
    function getTokenExtension(address _platform) public constant returns (address) {
        return store.get(platformToExtension, _platform);
    }

    /**
    * @dev Checks if a user has access rights and an owner of a token with provided symbol
    *
    * @param _symbol symbol associated with some token
    * @param _user a user which should be tested for ownership
    *
    * @return `true` if a user is an owner, `false` otherwise
    */
    function isAssetOwner(bytes32 _symbol, address _user) public constant returns (bool) {
        return AssetsManagerAggregations.isAssetOwner(store, platformToExtension, _symbol, getAssetBySymbol(_symbol), _user);
    }

    /**
    * @dev Checks if a token with such symbol is registered in the system
    *
    * @param _symbol symbol associated with some token
    *
    * @return `true` if token with passed symbol exists, `false` otherwise
    */
    function isAssetSymbolExists(bytes32 _symbol) public constant returns (bool) {
        return getAssetBySymbol(_symbol) != 0x0;
    }

    /**
    * @dev Gets token's address which is associated with a symbol
    *
    * @param _symbol symbol associated with some token
    *
    * @return address of a token with passed symbol
    */
    function getAssetBySymbol(bytes32 _symbol) public constant returns (address) {
        return ERC20ManagerInterface(lookupManager("ERC20Manager")).getTokenAddressBySymbol(_symbol);
    }

    /**
    * @dev STATISTICS.
    * Returns all platforms where user is participating: has an asset in ownership or owning the whole platform.
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _user user
    *
    * @return _platforms list of platforms. Could contain repeated platforms so it is recommended to sift duplicates
    */
    function getParticipatingPlatformsForUser(address _user) public constant returns (address[] _platforms) {
        PlatformsManagerInterface _platformsManager = PlatformsManagerInterface(lookupManager("PlatformsManager"));
        uint _partricipatedPlatformsCount = store.count(userToParticipatedPlatforms, bytes32(_user));
        _platforms = new address[](_platformsManager.getPlatformsForUserCount(_user) + _partricipatedPlatformsCount);
        uint _platformIdx;
        for (_platformIdx = 0; _platformIdx < _partricipatedPlatformsCount; ++_platformIdx) {
            _platforms[_platformIdx] = store.get(userToParticipatedPlatforms, bytes32(_user), _platformIdx);
        }
        for (uint _userPlatformIdx = 0; _platformIdx < _platforms.length; ++_platformIdx) {
            _platforms[_platformIdx] = _platformsManager.getPlatformForUserAtIndex(_user, _userPlatformIdx++);
        }
    }

    /**
    * @dev Gets a number of assets in a platform where passed user is an owner.
    *
    * @param _platform hosting platform
    * @param _owner user to be checked for ownership
    *
    * @return a number of assets in user's ownership
    */
    function getAssetsForOwnerCount(address _platform, address _owner) public constant returns (uint) {
        return AssetsManagerAggregations.getAssetsForOwnerCount(getTokenExtension(_platform), _owner);
    }

    /**
    * @dev Returns the exact asset symbol hosted in a platform with passed user as an owner by accessing it by index.
    *
    * @param _platform hosting platform
    * @param _owner user to be checked for ownership
    * @param _idx index of a symbol. Should no more than number of assets for this owner minus 1
    *
    * @return symbol of an asset
    */
    function getAssetForOwnerAtIndex(address _platform, address _owner, uint _idx) public constant returns (bytes32) {
        return AssetsManagerAggregations.getAssetForOwnerAtIndex(getTokenExtension(_platform), _owner, _idx);
    }

    /**
    * @dev STATISTICS.
    * Returns number of assets that are in ownership by an owner regarding the whole system.
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _owner user to be checked for ownership
    *
    * @return number of assets
    */
    function getSystemAssetsForOwnerCount(address _owner) public constant returns (uint) {
        return AssetsManagerAggregations.getSystemAssetsForOwnerCount(store, userToParticipatedPlatforms, userWithPlatformToOwnedSymbols, _owner);
    }

    /**
    * @dev STATISTICS.
    * Returns assets that are in ownership by an owner regarding the whole system.
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _owner user to be checked for ownership
    *
    * @return {
    *   _tokens: list of tokens found in ownership of passed user
    *   _tokenPlatforms: associated platforms where found tokens are hosted
    *   _totalSupplies: associated total supplies for returned tokens
    * }
    */
    function getSystemAssetsForOwner(address _owner) public constant returns (address[] _tokens, address[] _tokenPlatforms, uint[] _totalSupplies) {
        uint _assetsCount = getSystemAssetsForOwnerCount(_owner);
        _tokens = new address[](_assetsCount);
        _tokenPlatforms = new address[](_assetsCount);
        _totalSupplies = new uint[](_assetsCount);

        bytes32 _ownerKey = bytes32(_owner);
        uint _platformsCount = store.count(userToParticipatedPlatforms, _ownerKey);
        uint _assetPointer;
        address _platform;
        bytes32 _symbolKey;
        for (uint _platformIdx = 0; _platformIdx < _platformsCount; ++_platformIdx) {
            _platform = store.get(userToParticipatedPlatforms, _ownerKey, _platformIdx);
            ChronoBankPlatformInterface _chronoBankPlatform = ChronoBankPlatformInterface(_platform);
            _symbolKey = keccak256(_owner, _platform);
            uint _symbolsCount = store.count(userWithPlatformToOwnedSymbols, _symbolKey);
            if (_symbolsCount != 0) {
                _tokenPlatforms[_assetPointer] = _platform;
            }
            bytes32 _symbol;
            for (uint _symbolIdx = 0; _symbolIdx < _symbolsCount; ++_symbolIdx) {
                _symbol = store.get(userWithPlatformToOwnedSymbols, _symbolKey, _symbolIdx);
                _tokens[_assetPointer] = _chronoBankPlatform.proxies(_symbol);
                _totalSupplies[_assetPointer] = _chronoBankPlatform.totalSupply(_symbol);
                _assetPointer += 1;
            }
        }
    }

    /**
    * @dev STATISTICS.
    * Returns list of owners (managers) that owns or has access rights to a token with passed symbolWithPlatformToUsers
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _symbol symbol associated with some token
    *
    * @return _managers list of owners
    */
    function getManagersForAssetSymbol(bytes32 _symbol) public constant returns (address[] _managers) {
        address _token = getAssetBySymbol(_symbol);
        address _platform = ChronoBankAssetProxyInterface(_token).chronoBankPlatform();
        _managers = store.get(symbolWithPlatformToUsers, keccak256(_symbol, _platform));
    }

    /**
    * @dev STATISTICS.
    * Returns owners (managers) that has something in ownership inside user's ecosystem (in platforms that passed user owns).
    *
    * DEPRECATED. WILL BE REMOVED IN NEXT RELEASES
    *
    * @param _owner user
    *
    * @return list of managers
    */
    function getManagers(address _owner) public constant returns (address[]) {
        return AssetsManagerAggregations.getManagers(store, symbolWithPlatformToUsers, lookupManager("PlatformsManager"), _owner);
    }

    /** Helper functions */

    /**
    * @dev Binds some internal variables during token extension setup.
    * PRIVATE
    */
    function _setupTokenExtension(address _platform, address _tokenExtension) private {
        assert(EventsHistory(getEventsHistory()).authorize(_tokenExtension));

        store.add(tokenExtensions, _tokenExtension);
        store.set(platformToExtension, _platform, _tokenExtension);
    }

    /** Events emitting */

    function _emitError(uint _errorCode) private returns (uint) {
        AssetsManagerEmitter(getEventsHistory()).emitError(_errorCode);
        return _errorCode;
    }

    function _emitTokenExtensionRequested(address _platform, address _tokenExtension) private {
        AssetsManagerEmitter(getEventsHistory()).emitTokenExtensionRequested(_platform, _tokenExtension);
    }

    function _emitTokenExtensionRegistered(address _platform, address _tokenExtension) private {
        AssetsManagerEmitter(getEventsHistory()).emitTokenExtensionRegistered(_platform, _tokenExtension);
    }

    function _emitTokenExtensionUnregistered(address _tokenExtension) private {
        AssetsManagerEmitter(getEventsHistory()).emitTokenExtensionUnregistered(_tokenExtension);
    }
}
