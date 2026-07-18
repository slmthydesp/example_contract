// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

contract TokenBank is IERC1363Receiver {
    IERC20 public immutable token;

    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    /// @notice Deposit tokens via approve + transferFrom
    /// @param amount The amount of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw deposited tokens
    /// @param amount The amount of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Insufficient deposit");

        deposits[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice ERC1363 转账回调 —— 在回调中记录用户的存款金额
    /// @dev 由 ERC1363 Token 在 transferAndCall / transferFromAndCall 时自动调用
    /// @param operator 发起转账操作的地址（transferAndCall 时等于 from，transferFromAndCall 时为 spender）
    /// @param from 资金从哪个地址转出（即存款用户）
    /// @param amount 转账金额
    /// @param data 附加数据（本合约忽略）
    /// @return IERC1363Receiver.onTransferReceived.selector
    function onTransferReceived(
        address operator,
        address from,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4) {
        // 安全检查：只有 Bank 关联的 Token 才能触发存款记录
        require(msg.sender == address(token), "Only bank token");

        deposits[from] += amount;
        emit Deposited(from, amount);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /// @notice Get total token balance held by the bank
    function bankBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
