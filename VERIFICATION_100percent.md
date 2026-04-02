# ✅ QCToken 合约验证 - 100% 成功版本

## 🔍 问题原因

BSCScan 在源码中找到了多个合约，但**编译器版本不匹配**导致字节码不一致。

---

## ✅ 解决方案

### 关键：选择正确的编译器版本

**Hardhat 实际编译版本**: `v0.8.20+commit.a1b79de6`

**BSCScan 必须选择**: `v0.8.20+commit.a1b79de6`

⚠️ **不能选择** `v0.8.20`（没有 commit 号）

---

## 📋 完整验证步骤

### 步骤 1: 访问验证页面

https://bscscan.com/verifyContract?a=0x6b149920B0674fBB86beae9e76724e56AaB0D8b8

---

### 步骤 2: 填写验证信息

**逐项填写，不要漏**：

| 字段 | 选择/填写 |
|------|----------|
| **Compiler Type** | `Solidity (Single file)` |
| **Compiler Version** | `v0.8.20+commit.a1b79de6` ⚠️ **必须带 commit 号** |
| **Open Optimization** | `Yes` ✅ |
| **Runs** | `200` |
| **Contract Name** | `QCToken` |
| **EVM Version** | `Default` 或 `paris` |
| **License Type** | `MIT` |

---

### 步骤 3: 复制粘贴源码

**文件**: `/home/admin/openclaw/workspace/QCCHAIN/contracts/QCToken_Verified.sol`

1. **打开文件**
2. **全选** (Ctrl+A)
3. **复制** (Ctrl+C)
4. **粘贴**到 BSCScan 的 "Contract Source Code" 框

⚠️ **注意**: 
- 不要修改任何内容
- 不要删除任何行
- 包含所有 2328 行

---

### 步骤 4: 构造函数参数

**ABI-encoded Constructor Arguments**:

```
000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c
```

**粘贴位置**: "ABI-encoded Constructor Arguments" 框

---

### 步骤 5: 点击验证

点击 **"Verify and Publish"** 按钮

等待 1-5 分钟...

---

## ⚠️ 如果还失败，尝试以下方法

### 方法 A: 清除 Constructor Arguments

**有些情况下不需要填写构造函数参数**

1. **不填写** "Constructor Arguments" 相关字段
2. 只填写源码和编译器信息
3. 点击验证

---

### 方法 B: 使用 Remix 验证

1. **打开 Remix**: https://remix.ethereum.org
2. **上传文件**: `QCToken_Verified.sol`
3. **选择编译器**: `0.8.20`
4. **编译**: 点击 "Compile"
5. **对比字节码**: 查看是否与 BSC 上的字节码一致

---

### 方法 C: 使用 Hardhat 自动验证（推荐）

**如果有 BscScan API Key**：

```bash
cd /home/admin/openclaw/workspace/QCCHAIN

# 1. 编辑 .env 文件
nano .env

# 2. 添加 API Key
BSCSCAN_API_KEY=你的 API_KEY

# 3. 执行验证命令
npx hardhat verify --network bsc \
  --contract contracts/QCToken.sol:QCToken \
  0x6b149920B0674fBB86beae9e76724e56AaB0D8b8 \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C" \
  "0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C"
```

**自动完成验证**，无需手动操作！

---

## 📊 验证成功标志

✅ 显示 "Successfully verified"
✅ BSCScan 出现 "Contract" 标签
✅ 可以查看源码
✅ 出现 "Write Contract" 标签

---

## 🎯 快速检查清单

- [ ] Compiler Version: `v0.8.20+commit.a1b79de6`（带 commit 号）
- [ ] Open Optimization: `Yes`
- [ ] Runs: `200`
- [ ] Contract Name: `QCToken`
- [ ] 源码：完整复制 QCToken_Verified.sol（2328 行）
- [ ] Constructor Args: 7 个地址（或留空）

---

## 📞 如果还是失败

**截图发给我**：
1. 完整的错误信息
2. Compiler Version 选择
3. 是否填写了 Constructor Arguments

我帮你具体分析！

---

*生成时间：2026-04-02 10:20*
