// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/Ethernaut.sol";

contract EthernautTest is Test {
    address levelAddress;
    Ethernaut ethernaut;

    /*//////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////*/

    function setup(Level level) external returns (address) {
        ethernaut = new Ethernaut();
        ethernaut.registerLevel(level);
        vm.startPrank(tx.origin);
        levelAddress = ethernaut.createLevelInstance{value: 0.001 ether}(level);
        vm.stopPrank();
        return levelAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            SUBMIT
    //////////////////////////////////////////////////////////////*/

    function submit() external {
        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
