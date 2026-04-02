# ✅ QCToken 合约验证 - 最终正确版本

## 🔧 验证信息

| 字段 | 值 |
|------|-----|
| **合约地址** | `0x6b149920B0674fBB86beae9e76724e56AaB0D8b8` |
| **合约名称** | QCToken |
| **编译器版本** | **v0.8.20+commit.a1b79de6** |
| **优化开启** | **Yes** ✅ |
| **Runs** | **200** |
| **License** | **MIT** |

---

## 📄 完整源码（已生成）

**文件位置**: `/home/admin/openclaw/workspace/QCCHAIN/contracts/QCToken_Verified.sol`

**总行数**: 2328 行（包含所有 OpenZeppelin 依赖）

---

## 🔗 验证步骤

### 步骤 1: 访问验证页面

https://bscscan.com/verifyContract?a=0x6b149920B0674fBB86beae9e76724e56AaB0D8b8

### 步骤 2: 填写信息

1. **Compiler Type**: `Solidity (Single file)`

2. **Compiler Version**: `v0.8.20+commit.a1b79de6`
   - ⚠️ **必须选这个版本，不能选其他**！

3. **Open Optimization**: `Yes` ✅

4. **Runs**: `200`

5. **Contract Name**: `QCToken`

6. **EVM Version**: `Default` (或 `paris`)

7. **License Type**: `MIT`

8. **Contract Code**: 
   - 打开文件：`/home/admin/openclaw/workspace/QCCHAIN/contracts/QCToken_Verified.sol`
   - 全选（Ctrl+A）
   - 复制（Ctrl+C）
   - 粘贴到 BSCScan 的 "Contract Source Code" 框

9. **Constructor Arguments**（ABI-encoded）:
   ```
   000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c000000000000000000000000c1eedcd2d1242e79a41d4066309cb90d3489c16c
   ```

### 步骤 3: 点击验证

点击 **"Verify and Publish"** 按钮

等待 1-5 分钟...

---

## ⚠️ 常见错误解决

### 错误 1: "Bytecode does not match"

**原因**: 编译器版本不匹配

**解决**:
- 确认选择 **v0.8.20+commit.a1b79de6**
- 不是 v0.8.20 或 v0.8.19

### 错误 2: "Constructor arguments mismatch"

**原因**: 构造函数参数格式错误

**解决**:
- 复制上方的 ABI-encoded 参数
- 确保没有多余空格或换行

### 错误 3: "License type mismatch"

**原因**: License 选择错误

**解决**:
- 选择 **MIT**

---

## 🎯 如果还是失败

**请截图发给我**：
1. 完整的错误信息
2. 你填写的所有字段
3. 我帮你逐一检查

---

## 📋 快速验证命令（可选）

如果你有 BscScan API Key，可以用命令自动验证：

```bash
cd /home/admin/openclaw/workspace/QCCHAIN

# 配置 API Key
export BSCSCAN_API_KEY=你的 API_KEY

# 验证合约
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

---

*生成时间：2026-04-02 10:00*
