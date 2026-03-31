# QC Chain 部署指南

## ✅ 已完成

- [x] 步骤 1: 依赖安装 - **完成**
- [x] 步骤 2: 运行测试 - **完成** (9/9 测试通过)
- [x] 步骤 3: Git 初始化 - **完成** (本地 commit 已完成)
- [ ] 步骤 4: 测试网部署 - **待完成** (需要你的 API Key)

---

## 📋 后续操作

### 1️⃣ 推送到 GitHub

**方法 A: 使用 GitHub CLI (推荐)**
```bash
cd /home/admin/openclaw/workspace/QCCHAIN
gh auth login  # 登录 GitHub
git push -u origin main
```

**方法 B: 使用 Personal Access Token**
```bash
cd /home/admin/openclaw/workspace/QCCHAIN
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx  # 替换为你的 token
./push-to-github.sh
```

**方法 C: 手动推送**
```bash
cd /home/admin/openclaw/workspace/QCCHAIN
git remote set-url origin https://github.com/du118/QCCHAIN.git
git push -u origin main
# 输入 GitHub 用户名和密码
```

---

### 2️⃣ 部署到 Sepolia 测试网

#### 准备工作

1. **获取 Sepolia ETH**
   - 访问 [Sepolia Faucet](https://sepoliafaucet.com/)
   - 用你的钱包地址领取测试 ETH

2. **获取 Alchemy API Key**
   - 访问 [Alchemy](https://www.alchemy.com/)
   - 注册账号并创建 Sepolia App
   - 复制 HTTP API URL

3. **获取 Etherscan API Key** (用于合约验证)
   - 访问 [Etherscan](https://etherscan.io/myapikey)
   - 注册并创建 API Key

#### 配置 .env 文件

编辑 `/home/admin/openclaw/workspace/QCCHAIN/.env`:

```bash
# 你的钱包私钥（不要用主网私钥！）
PRIVATE_KEY=你的私钥

# Alchemy Sepolia RPC URL
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/你的 API_KEY

# Etherscan API Key
ETHERSCAN_API_KEY=你的 Etherscan_API_KEY

# 代币分配地址（替换为你的地址）
FOUNDER_ADDRESS=你的地址
TEAM_ADDRESS=团队地址
MINING_ADDRESS=挖矿地址
ECOSYSTEM_ADDRESS=生态地址
MARKETING_ADDRESS=市场地址
COMMUNITY_ADDRESS=社区地址
MAINTENANCE_ADDRESS=维护地址
```

#### 执行部署

```bash
cd /home/admin/openclaw/workspace/QCCHAIN
npx hardhat run scripts/deploy.js --network sepolia
```

部署成功后会输出：
- 所有合约地址
- 代币信息
- 挖矿配置

---

### 3️⃣ 验证合约

部署脚本会自动验证合约。如果失败，手动验证：

```bash
# 验证 QCToken
npx hardhat verify --network sepolia \
  --contract contracts/QCToken.sol:QCToken \
  DEPLOYED_CONTRACT_ADDRESS \
  创始人地址 团队地址 挖矿地址 生态地址 市场地址 社区地址 维护地址

# 验证其他合约...
```

---

### 4️⃣ 添加到钱包

部署完成后，将 QC 代币添加到 MetaMask:

1. 打开 MetaMask
2. 点击"导入代币"
3. 输入 QCToken 合约地址
4. 代币符号：QC
5. 小数：18

---

## 🔐 安全提醒

1. **永远不要将私钥提交到 Git**
   - `.env` 文件已在 `.gitignore` 中
   - 使用 `.env.example` 作为模板

2. **测试网和主网分开**
   - 测试网可以用小额账户
   - 主网务必使用硬件钱包

3. **合约审计**
   - 主网上线前必须通过 Certik 审计
   - 目标评分：≥96 分

---

## 📞 需要帮助？

如果部署过程中遇到问题：
1. 检查错误信息
2. 确保有足够的 Sepolia ETH
3. 确认 RPC URL 和 API Key 正确
4. 查看 Hardhat 文档：https://hardhat.org

---

*生成时间：2026-03-31 19:00*
