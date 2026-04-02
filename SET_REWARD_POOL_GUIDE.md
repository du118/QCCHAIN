# 🔧 挖矿合约设置指南

## ⚠️ 问题：合约未验证

你的挖矿合约 **还没有验证源码**，所以 BSCScan 上没有 "Write Contract" 功能。

---

## ✅ 解决方案（2 种）

### 方案 1: 在 BSCScan 验证合约（推荐）

**步骤**：

1. **访问验证页面**
   https://bscscan.com/verifyContract?a=0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f

2. **填写信息**
   ```
   Compiler Type: Solidity (Single file)
   Compiler Version: v0.8.20+commit.a1b79de6
   Open Optimization: Yes
   Runs: 200
   ```

3. **上传合约源码**
   - 复制 `contracts/QCStaking.sol` 的内容
   - 粘贴到 "Enter the Solidity Contract Code"

4. **点击 "Verify and Publish"**

5. **等待审核**（约 1-5 分钟）

6. **验证成功后**，就会出现 "Write Contract" 标签

---

### 方案 2: 直接用代码调用（无需验证）

**使用 Remix IDE**：

1. **访问 Remix**
   https://remix.ethereum.org

2. **连接钱包**
   - 左侧 "Deploy & Run Transactions"
   - Environment: Injected Provider - MetaMask
   - 连接你的新钱包

3. **编译合约**
   - 新建文件 `QCStaking.sol`
   - 粘贴合约源码
   - 编译（Solidity Compiler）

4. **部署/调用**
   - Deploy & Run Transactions
   - At Address: `0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f`
   - 点击 "At Address" 按钮

5. **调用 `setRewardPool` 函数**
   - 输入：`3000000000000000000000000` (300 万 QC，18 位小数)
   - 点击 transact
   - 确认交易

---

## 📋 快速验证合约（我帮你准备材料）

### 合约源码

文件位置：`/home/admin/openclaw/workspace/QCCHAIN/contracts/QCStaking.sol`

### 验证所需信息

| 字段 | 值 |
|------|-----|
| **合约地址** | 0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f |
| **编译器版本** | v0.8.20+commit.a1b79de6 |
| **优化** | Yes |
| **Runs** | 200 |
| **License** | MIT |

---

## 🎯 最简单方法：用 Remix

**推荐用 Remix，步骤**：

1. 打开 https://remix.ethereum.org
2. 连接钱包（MetaMask）
3. 切换到 BSC 主网
4. At Address: `0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f`
5. 调用 `setRewardPool(3000000000000000000000000)`
6. 确认交易

---

## 🔗 直接链接

**Remix IDE**:  
https://remix.ethereum.org

**BSCScan 验证**:  
https://bscscan.com/verifyContract?a=0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f

**合约交易记录**（已执行的配置）:  
https://bscscan.com/address/0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f

---

*生成时间：2026-04-01 11:25*
