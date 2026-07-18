# TokenBank

## 已知问题

### 直接转账导致 Token 永久锁死

**问题描述：**

如果用户绕过 `TokenBank.deposit()` 方法，直接通过调用 `MyToken.transfer(tokenBankAddress, amount)` 向 TokenBank 合约地址转账，会导致以下后果：

1. Token 确实转到了 TokenBank 合约地址上，`bankBalance()` 会增加；
2. 但 `deposits[user]` 映射**不会更新**，因为没有走 `deposit()` 函数；
3. 用户后续调用 `withdraw()` 时，`deposits[msg.sender]` 为 0，无法提取；
4. 这些 Token 将被**永久锁死**在 TokenBank 合约中，任何人都无法取出。

**根因：**

ERC20 的 `transfer` 方法是一种"推送"模式——发送方主动扣减自己的余额并增加目标地址的余额，目标地址（TokenBank）完全是被动方，没有任何钩子或回调机制可以拒绝接收或感知到转账的发生。因此 TokenBank 无法在 ERC20 `transfer` 发生时同步更新内部的 `deposits` 记账。

**预防措施：**

用户在使用 TokenBank 时，务必通过 `deposit()` 方法进行存款操作，不要直接向合约地址转账。
