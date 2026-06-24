// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";

contract BigBank is Bank {
    // 1.1 要求存款金额 > 0.001 ether
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be > 0.001 ether");
        _;
    }

    // 重写 deposit，增加最小存款金额限制
    function deposit() external payable override minDeposit {
        _deposit();
    }

    // 重写 receive，直接向合约转账时也要求 > 0.001 ether
    receive() external payable override minDeposit {
        _deposit();
    }

    // 1.2 支持转移管理员
    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid new admin address");
        admin = newAdmin;
    }
}
