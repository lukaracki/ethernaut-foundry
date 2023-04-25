// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./GoodSamaritan.sol";
import "../BaseLevel.sol";

contract GoodSamaritanFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        GoodSamaritan instance = new GoodSamaritan();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        _player;
        return GoodSamaritan(_instance).coin().balances(address(GoodSamaritan(_instance).wallet())) > 0;
    }
}
