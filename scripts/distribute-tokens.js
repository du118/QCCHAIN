const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 执行 QC 代币分配...\n");
  
  // QCToken 合约地址
  const qcTokenAddress = "0x6b149920B0674fBB86beae9e76724e56AaB0D8b8";
  
  // 获取部署者
  const [deployer] = await ethers.getSigners();
  console.log("📝 执行者地址:", deployer.address);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 BNB 余额:", ethers.formatEther(balance), "BNB\n");
  
  // 获取 QCToken 合约
  const QCToken = await ethers.getContractFactory("QCToken");
  const qcToken = QCToken.attach(qcTokenAddress);
  
  // 检查代币分配状态
  const distributionCompleted = await qcToken.distributionCompleted();
  console.log("📊 代币分配状态:", distributionCompleted ? "已完成" : "未执行");
  
  if (distributionCompleted) {
    console.log("✅ 代币分配已完成！");
    
    // 查询各地址余额
    const addresses = {
      "创始人": deployer.address,
      "团队": deployer.address,
      "生态": deployer.address,
      "市场": deployer.address,
      "社区": deployer.address,
      "维护": deployer.address,
    };
    
    console.log("\n💰 各地址 QC 余额:");
    for (const [name, addr] of Object.entries(addresses)) {
      const balance = await qcToken.balanceOf(addr);
      console.log(`  ${name}: ${ethers.formatEther(balance)} QC`);
    }
    
    const totalSupply = await qcToken.totalSupply();
    console.log("\n📊 总供应量:", ethers.formatEther(totalSupply), "QC");
    
    return;
  }
  
  // 执行代币分配
  console.log("\n📦 开始执行代币分配...\n");
  
  const tx = await qcToken.executeDistribution();
  console.log("⏳ 交易发送中...");
  console.log("交易哈希:", tx.hash);
  
  await tx.wait();
  console.log("✅ 交易确认！");
  
  // 验证分配结果
  const founderBalance = await qcToken.balanceOf(deployer.address);
  console.log("\n🎉 代币分配完成！");
  console.log("💰 你的 QC 余额:", ethers.formatEther(founderBalance), "QC");
  
  // 查询合约余额（应该是 0）
  const contractBalance = await qcToken.balanceOf(qcTokenAddress);
  console.log("📦 合约剩余:", ethers.formatEther(contractBalance), "QC");
  
  console.log("\n============================================================");
  console.log("✅ QC 代币已成功分配到你的钱包！");
  console.log("============================================================");
  console.log("\n📱 在钱包中查看:");
  console.log("1. 打开你的 Web3 钱包");
  console.log("2. 切换到 BSC 主网");
  console.log("3. 添加代币合约地址:");
  console.log("   0x6b149920B0674fBB86beae9e76724e56AaB0D8b8");
  console.log("4. 查看余额（约 17,100,000 QC）");
  console.log("\n🔍 在 BscScan 查看:");
  console.log("https://bscscan.com/token/0x6b149920B0674fBB86beae9e76724e56AaB0D8b8?a=0xC1Eedcd2D1242E79a41d4066309CB90d3489C16C");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
