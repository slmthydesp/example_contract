// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";

contract Bank is IBank {
    address public admin;
    mapping(address => uint256) public balances;

    // 记录存款金额前 3 名的地址（降序排列）
    address[3] public topDepositors;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // 通过 Metamask 直接向合约转账 ETH 时触发
    receive() external payable virtual {
        _deposit();
    }

    // 主动调用 deposit 函数存款
    function deposit() external payable virtual {
        _deposit();
    }

    // 内部存款逻辑
    function _deposit() internal {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
        _updateTop3(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

    // 更新存款前 3 名（按余额降序）
    function _updateTop3(address _depositor) private {
        uint256 balance = balances[_depositor];

        // 1. 如果该地址已经在 top3 中，先移除
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i] == _depositor) {
                // 将后面的元素前移
                for (uint j = i; j < 2; j++) {
                    topDepositors[j] = topDepositors[j + 1];
                }
                topDepositors[2] = address(0);
                break;
            }
        }

        // 2. 按降序插入到正确位置
        for (uint i = 0; i < 3; i++) {
            if (
                topDepositors[i] == address(0) ||
                balance > balances[topDepositors[i]]
            ) {
                // 将 i及之后的元素后移
                for (uint j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = _depositor;
                break;
            }
        }
    }

    // 管理员提取合约中所有 ETH
    function withdraw() external onlyAdmin {
        uint256 amount = address(this).balance;
        require(amount > 0, "No balance to withdraw");

        (bool success, ) = payable(admin).call{value: amount}("");
        require(success, "Withdraw failed");

        emit WithdrawAll(admin, amount);
    }

    // 一次性查询前 3 名（Remix 中方便调试）
    function getTopDepositors() external view returns (address[3] memory) {
        return topDepositors;
    }

    // 查询合约当前 ETH 余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
