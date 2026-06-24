// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";

contract Admin {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 取款函数：调用 IBank 接口的 withdraw 方法，将 bank 合约内的资金转移到 Admin 合约地址
    // 前提：Admin 合约地址需要被设置为 bank 合约的 admin（通过 BigBank.transferAdmin）
    function adminWithdraw(IBank bank) external onlyOwner {
        bank.withdraw();
    }

    // 将 Admin 合约中的 ETH 提取到指定地址，防止资金锁死
    function withdrawTo(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be > 0");
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // 接收 ETH（bank.withdraw() 会将 ETH 发送到本合约地址）
    receive() external payable {}

    // 查询本合约 ETH 余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
