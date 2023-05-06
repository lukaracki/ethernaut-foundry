// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../BaseLevel.sol";
import "./Switch.sol";

contract SwitchFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        Switch _switch = new Switch();
        return address(_switch);
    }

    function validateInstance(address payable _instance, address) public view override returns (bool) {
        Switch _switch = Switch(_instance);
        return _switch.switchOn() == true;
    }
}
