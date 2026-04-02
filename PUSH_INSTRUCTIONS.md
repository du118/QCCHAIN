# 🚀 推送 QC Chain 到 GitHub

## 当前状态

✅ 代码已本地 commit
- Commit 1: Initial commit: QC Chain core contracts
- Commit 2: Add deployment guides and verification scripts
- Commit 3: Add completion report

⏳ 等待推送到 GitHub

---

## 推送方法

### 方法 1: 使用 Personal Access Token (推荐)

#### 步骤 1: 创建 Token

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写说明：QC Chain Deployment
4. 选择权限：
   - ✅ `repo` (全部勾选)
   - ✅ `workflow`
5. 点击 "Generate token"
6. **复制 token** (只显示一次！) 格式：`ghp_xxxxxxxxxxxx`

#### 步骤 2: 推送代码

```bash
cd /home/admin/openclaw/workspace/QCCHAIN

# 方式 A: 临时使用 token
git remote set-url origin https://YOUR_USERNAME:ghp_xxxxxxxxxxxx@github.com/du118/QCCHAIN.git
git push -u origin main

# 方式 B: 使用环境变量
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
git remote set-url origin https://${GITHUB_TOKEN}@github.com/du118/QCCHAIN.git
git push -u origin main
```

---

### 方法 2: 使用 SSH Key

#### 步骤 1: 生成 SSH Key (如果没有)

```bash
ssh-keygen -t ed25519 -C "qcchain@du118.github.io"
cat ~/.ssh/id_ed25519.pub
```

#### 步骤 2: 添加到 GitHub

1. 复制上面输出的公钥内容
2. 访问 https://github.com/settings/keys
3. 点击 "New SSH key"
4. 粘贴公钥并保存

#### 步骤 3: 切换为 SSH 推送

```bash
cd /home/admin/openclaw/workspace/QCCHAIN
git remote set-url origin git@github.com:du118/QCCHAIN.git
git push -u origin main
```

---

### 方法 3: 使用 GitHub CLI

```bash
# 安装 gh (如果失败请使用方法 1 或 2)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# 登录并推送
gh auth login
git push -u origin main
```

---

## 验证推送

推送成功后，访问：
https://github.com/du118/QCCHAIN

应该能看到：
- ✅ 所有合约文件
- ✅ 部署脚本
- ✅ 测试文件
- ✅ 文档

---

## 快速命令

```bash
cd /home/admin/openclaw/workspace/QCCHAIN

# 检查当前状态
git status
git log --oneline

# 查看远程配置
git remote -v

# 推送
git push -u origin main

# 强制推送 (如果需要)
git push -f -u origin main
```

---

## 遇到问题？

### 错误：Authentication failed
- Token 可能已过期或错误
- 重新生成 token 并重试

### 错误：Permission denied
- 确保你是仓库所有者或有写入权限
- 检查 token 权限是否包含 `repo`

### 错误：Could not read Username
- 使用完整的 URL 格式：`https://TOKEN@github.com/USER/REPO.git`

---

*生成时间：2026-03-31 19:10*
