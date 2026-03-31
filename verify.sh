#!/bin/bash
# QC Chain 本地验证脚本

cd /home/admin/openclaw/workspace/QCCHAIN

echo "🔍 QC Chain 项目验证"
echo "===================="
echo ""

# 1. 检查依赖
echo "1️⃣  检查依赖安装..."
if [ -d "node_modules" ]; then
    echo "   ✅ node_modules 存在"
else
    echo "   ❌ node_modules 不存在，运行：npm install"
    exit 1
fi

# 2. 编译合约
echo ""
echo "2️⃣  编译合约..."
npx hardhat compile --force 2>&1 | grep -E "(Compiled|Error)" | head -5

# 3. 运行测试
echo ""
echo "3️⃣  运行测试..."
npx hardhat test 2>&1 | grep -E "(passing|failing)" | tail -2

# 4. 检查 Git 状态
echo ""
echo "4️⃣  Git 状态:"
git status --short | head -5
if [ -z "$(git status --short)" ]; then
    echo "   ✅ 工作区干净"
else
    echo "   ⚠️  有未提交的更改"
fi

# 5. 检查合约文件
echo ""
echo "5️⃣  合约文件:"
ls -lh contracts/*.sol | awk '{print "   📄", $9, "-", $5}'

# 6. 检查文档
echo ""
echo "6️⃣  文档:"
ls -lh *.md | awk '{print "   📄", $9, "-", $5}'

echo ""
echo "===================="
echo "✅ 验证完成！"
echo ""
echo "下一步:"
echo "1. 推送到 GitHub: git push -u origin main"
echo "2. 配置 .env 文件"
echo "3. 部署到 Sepolia: npx hardhat run scripts/deploy.js --network sepolia"
