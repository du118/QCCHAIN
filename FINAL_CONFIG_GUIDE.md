# 📋 挖矿合约最后配置指南

## ✅ 已验证

| 项目 | 状态 |
|------|------|
| **QCStaking 合约** | `0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f` |
| **QC 奖励池** | 3,000,000 QC ✅ 已到账 |
| **BNB 余额** | 约 0.005 BNB（足够配置） |

---

## 🔧 最后一步：设置奖励池总量

### 在 BSCScan 上操作

1. **访问合约页面**
   https://bscscan.com/address/0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f#writeContract

2. **连接钱包**
   - 点击右上角 "Connect to Web3"
   - 选择你的新钱包：`0xE8E6946b1111F618F78dDf04eaa01be8b3E38a51`

3. **找到 `setRewardPool` 函数**
   - 在 "Write Contract" 标签页
   - 向下滚动找到 `setRewardPool`

4. **填写参数**
   ```
   _totalReward: 3000000000000000000000000
   ```
   （这是 3,000,000 QC，18 位小数）

5. **点击 "Write" 并确认交易**
   - Gas 费约 0.001 BNB
   - 等待 3-5 秒确认

---

## ✅ 验证配置

### 检查奖励池

访问：
https://bscscan.com/address/0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f#readContract

查询以下函数：

1. **`totalRewardPool`**
   - 应该显示：`3000000000000000000000000` (300 万 QC)

2. **`rewardPerSecond`**
   - 应该显示：`95000000000000000` (0.095 QC/秒)

3. **`startTime`** 和 **`endTime`**
   - 应该显示：开始和结束时间戳

4. **`poolLength`**
   - 应该显示：`2` (QC 池 + BNB 池)

---

## 🎊 挖矿系统完全就绪！

### 配置完成后的参数

| 参数 | 值 |
|------|-----|
| **总奖励池** | 3,000,000 QC |
| **奖励速率** | 0.095 QC/秒 |
| **奖励时间** | 12 个月 |
| **质押池** | 2 个（QC + BNB） |
| **QC 池权重** | 50 (APY ~100%) |
| **BNB 池权重** | 40 (APY ~80%) |

---

## 📱 用户挖矿指南

### 如何参与 QC 质押挖矿？

**步骤 1: 准备 QC 代币**
- 确保钱包有 QC 代币（BSC 主网）
- 合约地址：`0x6b149920B0674fBB86beae9e76724e56AaB0D8b8`

**步骤 2: 访问挖矿页面**
- 官网挖矿页面（待上线）
- 或直接在 BSCScan 操作

**步骤 3: 批准 QC 代币**
- 在挖矿页面点击 "Approve QC"
- 确认交易（Gas 费约 0.001 BNB）

**步骤 4: 质押 QC**
- 输入质押数量
- 点击 "Stake"
- 确认交易

**步骤 5: 领取奖励**
- 奖励自动累积
- 随时可以领取
- 点击 "Claim Reward"

**步骤 6: 提取质押**
- 点击 "Withdraw"
- 输入提取数量
- 确认交易（同时自动领取奖励）

---

### BNB 质押挖矿

**步骤类似**：
1. 批准 BNB 代币
2. 质押 BNB
3. 领取 QC 奖励

---

## 🔗 相关链接

| 项目 | 链接 |
|------|------|
| **挖矿合约** | https://bscscan.com/address/0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f |
| **QC 代币** | https://bscscan.com/token/0x6b149920B0674fBB86beae9e76724e56AaB0D8b8 |
| **你的钱包** | https://bscscan.com/address/0xE8E6946b1111F618F78dDf04eaa01be8b3E38a51 |

---

## ✅ 检查清单

- [x] QCStaking 合约部署
- [x] 300 万 QC 转入合约
- [ ] 设置 `setRewardPool` 参数
- [ ] 验证所有配置
- [ ] BSCScan 合约验证
- [ ] 编写用户文档
- [ ] 官网挖矿页面上线

---

*生成时间：2026-04-01 11:10*
