// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/MagicNumber/MagicNumber.sol";
import "levels/MagicNumber/MagicNumberFactory.sol";
import "./utils/EthernautTest.sol";

interface IMagicNumber {
    function setSolver(address _solver) external;
}

contract MagicNumberTest is Test {
    function test_magicnumber() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        MagicNumberFactory magicNumberFactory = new MagicNumberFactory();
        address levelAddress = ethernautTest.setup(magicNumberFactory);

        // Exploit
        vm.startPrank(tx.origin);

        // RUNTIME CODE
        //
        // Push and store 42 to memory location 0x69
        // PUSH1 -> 0x60 --> PUSH1(0x2a)
        // PUSH1 -> 0x60 --> PUSH1(0x69)
        // MSTORE --> 0x52 --> MSTORE(0x2a, 0x69)
        // Return stored value from locaiton 0x69
        // PUSH1 -> 0x60 --> PUSH1(0x20)
        // PUSH1 -> 0x60 --> PUSH1(0x69)
        // RETURN --> 0xf3 --> RETURN(0x20, 0x69)

        // 0x60 0x2a 0x60 0x69 0x52 0x60 0x20 0x60 0x69 0xf3

        // INITIALIZATION CODE
        //
        // Use codecopy to copy the runtime code to memory location 0x00
        // PUSH1 -> 0x60 --> PUSH1(0x0a)
        // PUSH1 -> 0x60 --> PUSH1(___) -> offset -> 0x0a
        // PUSH0 -> 0x5f
        // CODECOPY --> 0x39 --> CODECOPY(0x0a, ___, 0x00)
        // return runtime opcode
        // PUSH1 -> 0x60 --> PUSH1(0x0a)
        // PUSH0 > 0x5f
        // RETURN --> 0xf3 --> RETURN(0x0a, 0x00)

        // 0x60 0x0a 0x60 0x0a 0x5f 0x39 0x60 0x0a 0x5f 0xf3

        // Combine the two codes
        // 0x60 0x0a 0x60 0x0a 0x5f 0x39 0x60 0x0a 0x5f 0xf3 0x60 0x2a 0x60 0x69 0x52 0x60 0x20 0x60 0x69 0xf3

        bytes memory bytecode =
            "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";

        address solver;

        assembly {
            solver := create(0, add(bytecode, 0x20), 0x1b)
        }

        IMagicNumber magicNumber = IMagicNumber(levelAddress);
        magicNumber.setSolver(solver);
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
