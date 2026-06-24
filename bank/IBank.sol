// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    event Deposit(address indexed from, uint256 amount);
    event WithdrawAll(address indexed admin, uint256 amount);

    function deposit() external payable;
    function withdraw() external;
    function getBalance() external view returns (uint256);
    function getTopDepositors() external view returns (address[3] memory);
}
