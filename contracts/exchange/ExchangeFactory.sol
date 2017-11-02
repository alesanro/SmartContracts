pragma solidity ^0.4.15;

import "./Exchange.sol";

contract ExchangeFactory {
    function createExchange() public returns (Exchange) {
        Exchange exchange = new Exchange();
        if (!exchange.transferContractOwnership(msg.sender)) {
            revert();
        }

        return exchange;
    }
}
