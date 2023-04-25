// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/DoubleEntryPoint/DoubleEntryPoint.sol";
import "levels/DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "./utils/EthernautTest.sol";

contract DetectionBot is IDetectionBot {
    address private vault;

    constructor(address _vault) {
        vault = _vault;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        address to;
        uint256 value;
        address origSender;
        bytes4 sig;

        assembly {
            sig := calldataload(0x64)
            origSender := calldataload(0xa8)
        }

        if (sig == bytes4(keccak256(abi.encodePacked("delegateTransfer(address,uint256,address)")))) {
            if (origSender == vault) {
                Forta(msg.sender).raiseAlert(user);
            }
        }
    }
}

contract DoubleEntryPointTest is Test {
    function test_doubleEntryPoint() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        DoubleEntryPointFactory doubleEntryPointFactory = new DoubleEntryPointFactory();
        address levelAddress = ethernautTest.setup(doubleEntryPointFactory);

        // Exploit
        vm.startPrank(tx.origin);
        DetectionBot detectionBot = new DetectionBot(DoubleEntryPoint(levelAddress).cryptoVault());
        DoubleEntryPoint(levelAddress).forta().setDetectionBot(address(detectionBot));
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
