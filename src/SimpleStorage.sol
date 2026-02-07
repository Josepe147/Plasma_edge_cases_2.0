// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 public value;

    function set(uint256 _value) external {
        value = _value;
    }
}
