const errorScope = {
    loc: 1000,
    user: 2000,
    crowdfunding: 3000,
    pending: 4000,
    storage: 5000,
    exchange: 6000,
    exchangeStock: 7000,
    vote: 8000,
    reward: 9000,
    contract: 10000,
    assets: 30000,
    timeholder: 12000,
    ercmanager: 13000,
    walletsmanager: 14000,
    chronobankplatform: 15000,
    platforms: 21000,
    tokenextension: 23000
}

const errorsLibrary = {
    UNAUTHORIZED: 0,
    OK: 1,
    MULTISIG_ADDED: 3,
    UNDEFINED: 0xDEFDEFDEF,
    OBJECT_ACCESS_DENIED_CONTRACT_OWNER_ONLY: 8,

    LOC_NOT_FOUND: errorScope.loc + 0,
    LOC_EXISTS: errorScope.loc + 1,
    LOC_INACTIVE: errorScope.loc + 2,
    LOC_SHOULD_NO_BE_ACTIVE: errorScope.loc + 3,
    LOC_INVALID_PARAMETER: errorScope.loc + 4,
    LOC_INVALID_INVOCATION: errorScope.loc + 5,
    LOC_ADD_CONTRACT: errorScope.loc + 6,
    LOC_SEND_ASSET: errorScope.loc + 7,
    LOC_REQUESTED_ISSUE_VALUE_EXCEEDED: errorScope.loc + 8,
    LOC_REISSUING_ASSET_FAILED: errorScope.loc + 9,
    LOC_REQUESTED_REVOKE_VALUE_EXCEEDED: errorScope.loc + 10,
    LOC_REVOKING_ASSET_FAILED: errorScope.loc + 11,

    USER_NOT_FOUND: errorScope.user + 0,
    USER_INVALID_PARAMETER: errorScope.user + 1,
    USER_ALREADY_CBE: errorScope.user + 2,
    USER_NOT_CBE: errorScope.user + 3,
    USER_SAME_HASH: errorScope.user + 4,
    USER_INVALID_REQURED: errorScope.user + 5,
    USER_INVALID_STATE: errorScope.user + 6,

    CROWDFUNDING_INVALID_INVOCATION: errorScope.crowdfunding + 0,
    CROWDFUNDING_ADD_CONTRACT: errorScope.crowdfunding + 1,
    CROWDFUNDING_NOT_ASSET_OWNER: errorScope.crowdfunding + 2,

    PENDING_NOT_FOUND: errorScope.pending + 0,
    PENDING_INVALID_INVOCATION: errorScope.pending + 1,
    PENDING_ADD_CONTRACT: errorScope.pending + 2,
    PENDING_DUPLICATE_TX: errorScope.pending + 3,
    PENDING_CANNOT_CONFIRM: errorScope.pending + 4,
    PENDING_PREVIOUSLY_CONFIRMED: errorScope.pending + 5,

    STORAGE_INVALID_INVOCATION: errorScope.storage + 0,

    EXCHANGE_INVALID_PARAMETER: errorScope.exchange + 0,
    EXCHANGE_INVALID_INVOCATION: errorScope.exchange + 1,
    EXCHANGE_INVALID_FEE_PERCENT: errorScope.exchange + 2,
    EXCHANGE_INVALID_PRICE: errorScope.exchange + 3,
    EXCHANGE_MAINTENANCE_MODE: errorScope.exchange + 4,
    EXCHANGE_TOO_HIGH_PRICE: errorScope.exchange + 5,
    EXCHANGE_TOO_LOW_PRICE: errorScope.exchange + 6,
    EXCHANGE_INSUFFICIENT_BALANCE: errorScope.exchange + 7,
    EXCHANGE_INSUFFICIENT_ETHER_SUPPLY: errorScope.exchange + 8,
    EXCHANGE_PAYMENT_FAILED: errorScope.exchange + 9,
    EXCHANGE_TRANSFER_FAILED: errorScope.exchange + 10,
    EXCHANGE_FEE_TRANSFER_FAILED: errorScope.exchange + 11,

    EXCHANGE_STOCK_NOT_FOUND: errorScope.exchangeStock + 0,
    EXCHANGE_STOCK_INVALID_PARAMETER: errorScope.exchangeStock + 1,
    EXCHANGE_STOCK_INVALID_INVOCATION: errorScope.exchangeStock + 2,
    EXCHANGE_STOCK_ADD_CONTRACT: errorScope.exchangeStock + 3,
    EXCHANGE_STOCK_UNABLE_CREATE_EXCHANGE: errorScope.exchangeStock + 4,

    VOTE_INVALID_PARAMETER: errorScope.vote + 0,
    VOTE_INVALID_INVOCATION: errorScope.vote + 1,
    VOTE_ADD_CONTRACT: errorScope.vote + 2,
    VOTE_LIMIT_EXCEEDED: errorScope.vote + 3,
    VOTE_POLL_LIMIT_REACHED: errorScope.vote + 4,
    VOTE_POLL_WRONG_STATUS: errorScope.vote + 5,
    VOTE_POLL_INACTIVE: errorScope.vote + 6,
    VOTE_POLL_NO_SHARES: errorScope.vote + 7,
    VOTE_POLL_ALREADY_VOTED: errorScope.vote + 8,
    VOTE_ACTIVE_POLL_LIMIT_REACHED: errorScope.vote + 9,
    VOTE_UNABLE_TO_ACTIVATE_POLL: errorScope.vote + 10,
    VOTE_OPTIONS_LIMIT_REACHED: errorScope.vote + 11,
    VOTE_POLL_SHOULD_BE_INACTIVE: errorScope.vote + 13,
    VOTE_POLL_DOES_NOT_EXIST: errorScope.vote + 14,
    VOTE_OPTION_CHOICE_OUT_OF_RANGE: errorScope.vote + 15,
    VOTE_OPTIONS_EMPTY_LIST: errorScope.vote + 16,
    VOTE_DETAILS_HASH_INVALID_PARAMETER: errorScope.vote + 17,
    VOTE_DEADLINE_INVALID_PARAMETER: errorScope.vote + 18,
    VOTE_HASH_INVALID_PARAMETER: errorScope.vote + 19,
    VOTE_SHARES_PERCENT_OUT_OF_RANGE: errorScope.vote + 20,
    VOTE_OPTION_INVALID_PARAMETER: errorScope.vote + 21,

    REWARD_NOT_FOUND: errorScope.reward + 0,
    REWARD_INVALID_PARAMETER: errorScope.reward + 1,
    REWARD_INVALID_INVOCATION: errorScope.reward + 2,
    REWARD_INVALID_STATE: errorScope.reward + 3,
    REWARD_INVALID_PERIOD: errorScope.reward + 4,
    REWARD_NO_REWARDS_LEFT: errorScope.reward + 5,
    REWARD_ASSET_TRANSFER_FAILED: errorScope.reward + 6,
    REWARD_ALREADY_CALCULATED: errorScope.reward + 7,
    REWARD_CALCULATION_FAILED: errorScope.reward + 8,
    REWARD_CANNOT_CLOSE_PERIOD: errorScope.reward + 9,
    REWARD_ASSET_ALREADY_REGISTERED: errorScope.reward + 10,

    CONTRACT_EXISTS: errorScope.contract + 0,
    CONTRACT_NOT_EXISTS: errorScope.contract + 1,

    TIMEHOLDER_ALREADY_ADDED: errorScope.timeholder + 0,
    TIMEHOLDER_INVALID_INVOCATION: errorScope.timeholder + 1,
    TIMEHOLDER_INVALID_STATE: errorScope.timeholder + 2,
    TIMEHOLDER_TRANSFER_FAILED: errorScope.timeholder + 3,
    TIMEHOLDER_WITHDRAWN_FAILED: errorScope.timeholder + 4,
    TIMEHOLDER_DEPOSIT_FAILED: errorScope.timeholder + 5,
    TIMEHOLDER_INSUFFICIENT_BALANCE: errorScope.timeholder + 6,
    TIMEHOLDER_LIMIT_EXCEEDED: errorScope.timeholder + 7,

    ERCMANAGER_INVALID_INVOCATION: errorScope.ercmanager + 0,
    ERCMANAGER_INVALID_STATE: errorScope.ercmanager + 1,
    ERCMANAGER_TOKEN_SYMBOL_NOT_EXISTS: errorScope.ercmanager + 2,
    ERCMANAGER_TOKEN_NOT_EXISTS: errorScope.ercmanager + 3,
    ERCMANAGER_TOKEN_SYMBOL_ALREADY_EXISTS: errorScope.ercmanager + 4,
    ERCMANAGER_TOKEN_ALREADY_EXISTS: errorScope.ercmanager + 5,
    ERCMANAGER_TOKEN_UNCHANGED: errorScope.ercmanager + 6,

    ASSETS_MANAGER_SYMBOL_ALREADY_EXISTS: errorScope.assets + 1,
    ASSETS_MANAGER_INVALID_INVOCATION: errorScope.assets + 2,
    ASSETS_MANAGER_EXTENSION_ALREADY_EXISTS: errorScope.assets + 3,

    ERROR_WALLET_INVALID_INVOCATION: errorScope.walletsmanager + 0,
    ERROR_WALLET_EXISTS: errorScope.walletsmanager + 1,
    ERROR_WALLET_OWNER_ONLY: errorScope.walletsmanager + 2,
    ERROR_WALLET_CANNOT_ADD_TO_REGISTRY: errorScope.walletsmanager + 3,
    ERROR_WALLET_UNKNOWN: errorScope.walletsmanager + 4,

    CHRONOBANK_PLATFORM_PROXY_ALREADY_EXISTS: errorScope.chronobankplatform + 0,
    CHRONOBANK_PLATFORM_CANNOT_APPLY_TO_ONESELF: errorScope.chronobankplatform + 1,
    CHRONOBANK_PLATFORM_INVALID_VALUE: errorScope.chronobankplatform + 2,
    CHRONOBANK_PLATFORM_INSUFFICIENT_BALANCE: errorScope.chronobankplatform + 3,
    CHRONOBANK_PLATFORM_NOT_ENOUGH_ALLOWANCE: errorScope.chronobankplatform + 4,
    CHRONOBANK_PLATFORM_ASSET_ALREADY_ISSUED: errorScope.chronobankplatform + 5,
    CHRONOBANK_PLATFORM_CANNOT_ISSUE_FIXED_ASSET_WITH_INVALID_VALUE: errorScope.chronobankplatform + 6,
    CHRONOBANK_PLATFORM_CANNOT_REISSUE_FIXED_ASSET: errorScope.chronobankplatform + 7,
    CHRONOBANK_PLATFORM_SUPPLY_OVERFLOW: errorScope.chronobankplatform + 8,
    CHRONOBANK_PLATFORM_NOT_ENOUGH_TOKENS: errorScope.chronobankplatform + 9,
    CHRONOBANK_PLATFORM_INVALID_NEW_OWNER: errorScope.chronobankplatform + 10,
    CHRONOBANK_PLATFORM_ALREADY_TRUSTED: errorScope.chronobankplatform + 11,
    CHRONOBANK_PLATFORM_SHOULD_RECOVER_TO_NEW_ADDRESS: errorScope.chronobankplatform + 12,
    CHRONOBANK_PLATFORM_ASSET_IS_NOT_ISSUED: errorScope.chronobankplatform + 13,
    CHRONOBANK_PLATFORM_INVALID_INVOCATION: errorScope.chronobankplatform + 17,

    PLATFORMS_ATTACHING_PLATFORM_ALREADY_EXISTS: errorScope.platforms + 1,
    PLATFORMS_PLATFORM_DOES_NOT_EXIST: errorScope.platforms + 2,
    PLATFORMS_INCONSISTENT_INTERNAL_STATE: errorScope.platforms + 3,

    TOKEN_EXTENSION_ASSET_TOKEN_EXISTS: errorScope.tokenextension + 1,
    TOKEN_EXTENSION_ASSET_COULD_NOT_BE_REISSUED: errorScope.tokenextension + 2,
    TOKEN_EXTENSION_ASSET_COULD_NOT_BE_REVOKED: errorScope.tokenextension + 3,
    TOKEN_EXTENSION_ASSET_OWNER_ONLY: errorScope.tokenextension + 4,
    TOKEN_EXTENSION_CANNOT_PASS_PLATFORM_OWNERSHIP: errorScope.tokenextension + 51,
    TOKEN_EXTENSION_CANNOT_CLAIM_PLATFORM_OWNERSHIP: errorScope.tokenextension + 52,
    TOKEN_EXTENSION_SENDER_DOES_NOT_SUPPORT_ASSET_FALLBACK: errorScope.tokenextension + 53,
    TOKEN_EXTENSION_CANNOT_PASS_ASSET_OWNERSHIP: errorScope.tokenextension + 54,
    TOKEN_EXTENSION_CANNOT_CLAIM_ASSET_OWNERSHIP: errorScope.tokenextension + 55,
}

module.exports = errorsLibrary
