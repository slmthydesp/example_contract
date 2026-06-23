// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract Counter {
    uint256 public counter;

    constructor(uint256 x) {
        counter = x;
    }

    function count() public {
        counter = counter + 1;
    }

    function add(uint256 x) public {
        counter = counter + x;
    }
}