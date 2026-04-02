const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 配置 QC 质押挖矿合约...\n");
  
  // 合约地址
  const qcTokenAddress = "0x6b149920B0674fBB86beae9e76724e56AaB0D8b8";
  const stakingAddress = "0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f";
  
  // 获取部署者
  const [deployer] = await ethers.getSigners();
  console.log("📝 配置者地址:", deployer.address);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 BNB 余额:", ethers.formatEther(balance), "BNB");
  
  const qcBalance = await (await ethers.getContractAt("QCToken", qcTokenAddress)).balanceOf(deployer.address);
  console.log("💰 QC 余额:", ethers.formatEther(qcBalance), "QC\n");
  
  // 获取合约实例
  const QCStaking = await ethers.getContractFactory("QCStaking");
  const qcStaking = QCStaking.attach(stakingAddress);
  
  // 1. 设置奖励时间（12 个月）
  console.log("⏳ 1/5 设置奖励时间...");
  const startTime = Math.floor(Date.now() / 1000) + 60; // 1 分钟后开始
  const endTime = startTime + (365 * 24 * 60 * 60); // 12 个月
  const tx1 = await qcStaking.setRewardTime(startTime, endTime);
  await tx1.wait();
  console.log("✅ 奖励时间设置成功");
  console.log("   开始时间:", new Date(startTime * 1000).toLocaleString("zh-CN"));
  console.log("   结束时间:", new Date(endTime * 1000).toLocaleString("zh-CN"));
  
  // 2. 添加 BNB 质押池
  console.log("\n⏳ 2/5 添加 BNB 质押池...");
  const bnbAddress = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  const tx2 = await qcStaking.addPool(bnbAddress, 40, true);
  await tx2.wait();
  console.log("✅ BNB 质押池添加成功");
  
  // 3. 验证质押池
  console.log("\n⏳ 3/5 验证质押池配置...");
  const poolLength = await qcStaking.poolLength();
  console.log("✅ 质押池数量:", poolLength);
  
  for (let i = 0; i < poolLength; i++) {
    const poolInfo = await qcStaking.getPoolInfo(i);
    console.log(`   池 ${i}: ${poolInfo.lpToken === qcTokenAddress ? "QC" : "BNB"} (权重：${poolInfo.allocPoint})`);
  }
  
  // 4. 转账 3,000,000 QC 到挖矿合约作为奖励池
  console.log("\n⏳ 4/5 转账奖励池到挖矿合约...");
  const QCToken = await ethers.getContractFactory("QCToken");
  const qcToken = QCToken.attach(qcTokenAddress);
  
  const rewardAmount = ethers.parseEther("3000000");
  const tx3 = await qcToken.transfer(stakingAddress, rewardAmount);
  await tx3.wait();
  console.log("✅ 3,000,000 QC 已转入挖矿合约");
  
  // 验证合约余额
  const contractQcBalance = await qcToken.balanceOf(stakingAddress);
  console.log("   挖矿合约 QC 余额:", ethers.formatEther(contractQcBalance), "QC");
  
  // 5. 设置奖励池总量
  console.log("\n⏳ 5/5 设置奖励池总量...");
  const tx4 = await qcStaking.setRewardPool(rewardAmount);
  await tx4.wait();
  console.log("✅ 奖励池总量设置成功");
  
  // 输出摘要
  console.log("\n" + "=".repeat(60));
  console.log("📋 配置完成摘要");
  console.log("=".repeat(60));
  console.log("网络：BSC 主网");
  console.log("配置者:", deployer.address);
  console.log();
  console.log("合约地址:");
  console.log("  QCStaking:", stakingAddress);
  console.log("  QCToken:", qcTokenAddress);
  console.log();
  console.log("挖矿配置:");
  console.log("  总奖励池：3,000,000 QC ✅");
  console.log("  奖励时间：12 个月 ✅");
  console.log("  奖励速率：0.095 QC/秒");
  console.log();
  console.log("质押池:");
  console.log("  池 0: QC 质押 (权重 50, APY ~100%) ✅");
  console.log("  池 1: BNB 质押 (权重 40, APY ~80%) ✅");
  console.log("  池 2: LP 质押 (待 PancakeSwap 上线后添加)");
  console.log();
  console.log("Gas 费用:");
  const newBalance = await ethers.provider.getBalance(deployer.address);
  const gasUsed = balance - newBalance;
  console.log("  消耗:", ethers.formatEther(gasUsed), "BNB");
  console.log("  剩余:", ethers.formatEther(newBalance), "BNB");
  console.log("=".repeat(60));
  
  console.log("\n🎉 挖矿合约配置完成！");
  console.log("\n📱 下一步:");
  console.log("1. 在 BSCScan 验证合约源码");
  console.log("2. 编写用户挖矿指南");
  console.log("3. 在官网和社区公布挖矿规则");
  console.log("4. PancakeSwap 上线后添加 LP 质押池");
  console.log("\n🔗 查看合约:");
  console.log("https://bscscan.com/address/" + stakingAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
