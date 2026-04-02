# 🚨 官网无法访问 - 修复指南

## 问题原因

GitHub Pages **需要在 Settings 中手动启用**才能访问。

---

## ✅ 修复步骤（5 分钟）

### 步骤 1: 打开 GitHub 仓库

**访问**: https://github.com/du118/QCCHAIN

---

### 步骤 2: 进入 Settings

1. 点击顶部 **"Settings"** 标签
2. 左侧菜单找到 **"Pages"**
   - 可能在 "Code and automation" 部分

---

### 步骤 3: 启用 GitHub Pages

**配置如下**：

| 设置 | 选择 |
|------|------|
| **Source** | `Deploy from a branch` |
| **Branch** | `main` |
| **Folder** | `/ (root)` |

**操作**：
1. Source 选择：`Deploy from a branch`
2. Branch 选择：`main`
3. Folder 选择：`/ (root)`
4. 点击 **"Save"** 按钮

---

### 步骤 4: 等待部署

- GitHub 会自动部署（2-5 分钟）
- 页面顶部会显示部署进度
- 部署完成后显示绿色勾

---

### 步骤 5: 访问官网

**官网地址**: https://du118.github.io/QCCHAIN/

**如果还打不开**：
1. 等待 5 分钟
2. 清除浏览器缓存
3. 使用无痕模式访问
4. 检查 GitHub Pages 状态

---

## 🔍 检查部署状态

### 在 GitHub Pages 页面查看

1. 返回 Settings → Pages
2. 查看顶部状态：
   - 🟡 **Building** - 正在部署
   - 🟢 **Published** - 已发布
   - 🔴 **Failed** - 部署失败

### 查看部署日志

1. Settings → Pages
2. 点击 "View deployments"
3. 查看最新部署记录

---

## ⚠️ 常见问题

### 问题 1: 404 Not Found

**原因**: GitHub Pages 还没部署完成

**解决**:
- 等待 5-10 分钟
- 刷新页面
- 清除浏览器缓存

---

### 问题 2: 空白页面

**原因**: 浏览器缓存问题

**解决**:
- 按 `Ctrl+F5` 强制刷新
- 或使用无痕模式访问

---

### 问题 3: Settings 中没有 Pages 选项

**原因**: 仓库权限问题

**解决**:
1. 确认你是仓库所有者
2. 检查仓库是否为公开
3. 如果是组织仓库，需要管理员权限

---

## 📸 截图指导

**如果找不到 Pages 设置**：

1. 打开仓库
2. 点击 Settings
3. 滚动左侧菜单
4. 找到 "Pages"（在 "Code and automation" 部分）

**如果还找不到**：
- 截图发给我
- 我帮你指出具体位置

---

## ✅ 验证清单

- [ ] 打开 GitHub 仓库
- [ ] 进入 Settings
- [ ] 找到 Pages 选项
- [ ] 选择 Branch: main
- [ ] 选择 Folder: / (root)
- [ ] 点击 Save
- [ ] 等待部署完成
- [ ] 访问 https://du118.github.io/QCCHAIN/
- [ ] 确认网站正常显示

---

## 🎯 快速验证

**部署成功后**，访问官网应该看到：

- 🔮 QC Logo
- "Quantum Coin | 量子币" 标题
- 合约地址显示
- 购买按钮
- 代币信息
- 路线图

---

## 📞 需要帮助？

**如果 10 分钟后还打不开**：

1. 截图 GitHub Pages 设置页面
2. 截图访问错误页面
3. 发给我，我帮你分析

---

*生成时间：2026-04-02 13:35*
