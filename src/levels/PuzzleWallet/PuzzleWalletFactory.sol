// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./PuzzleWallet.sol";
import "../BaseLevel.sol";

contract PuzzleWalletFactory is Level {
    event NewWallet(address indexed wallet);

    function createInstance(address _player) public payable override returns (address) {
        require(msg.value == 0.001 ether, "Must send 0.001 ETH to create instance");

        // deploy the PuzzleWallet logic
        PuzzleWallet walletLogic = new PuzzleWallet();

        _player;

        // deploy proxy and initialize implementation contract
        bytes memory data = abi.encodeWithSelector(PuzzleWallet.init.selector, 100 ether);
        PuzzleProxy proxy = new PuzzleProxy(address(this), address(walletLogic), data);
        PuzzleWallet instance = PuzzleWallet(address(proxy));

        // whitelist this contract to allow it to deposit ETH
        instance.addToWhitelist(address(this));
        instance.deposit{value: msg.value}();

        return address(proxy);
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        PuzzleProxy proxy = PuzzleProxy(_instance);
        return proxy.admin() == _player;
    }
}
