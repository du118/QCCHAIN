#!/bin/bash
# QC Chain GitHub 推送脚本
# 使用方法：./push-to-github.sh

cd /home/admin/openclaw/workspace/QCCHAIN

echo "📦 推送到 GitHub..."
echo ""

# 方法 1: 如果你有 GitHub CLI 安装
if command -v gh &> /dev/null; then
    echo "✅ 检测到 GitHub CLI"
    gh auth status
    git push -u origin main
    exit $?
fi

# 方法 2: 使用 Personal Access Token
if [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ 使用 GITHUB_TOKEN 推送"
    git remote set-url origin https://$GITHUB_TOKEN@github.com/du118/QCCHAIN.git
    git push -u origin main
    exit $?
fi

# 方法 3: 手动推送
echo "⚠️  需要认证，请选择以下方式之一："
echo ""
echo "1️⃣  使用 GitHub CLI:"
echo "   gh auth login"
echo "   git push -u origin main"
echo ""
echo "2️⃣  使用 Personal Access Token:"
echo "   export GITHUB_TOKEN=your_token_here"
echo "   ./push-to-github.sh"
echo ""
echo "3️⃣  手动推送:"
echo "   cd /home/admin/openclaw/workspace/QCCHAIN"
echo "   git push -u origin main"
echo ""
echo "📋 当前状态:"
git status
git remote -v
