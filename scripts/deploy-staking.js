const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 部署 QC 质押挖矿合约...\n");
  
  // QC Token 合约地址
  const qcTokenAddress = "0x6b149920B0674fBB86beae9e76724e56AaB0D8b8";
  
  // 获取部署者
  const [deployer] = await ethers.getSigners();
  console.log("📝 部署者地址:", deployer.address);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 BNB 余额:", ethers.formatEther(balance), "BNB\n");
  
  // 部署质押合约
  console.log("📦 部署 QCStaking 合约...");
  const QCStaking = await ethers.getContractFactory("QCStaking");
  const qcStaking = await QCStaking.deploy(qcTokenAddress);
  await qcStaking.waitForDeployment();
  const stakingAddress = await qcStaking.getAddress();
  console.log("✅ QCStaking 部署成功:", stakingAddress);
  
  // 配置奖励参数
  console.log("\n⚙️  配置奖励参数...");
  
  // 总奖励池：3,000,000 QC
  const totalReward = ethers.parseEther("3000000");
  await qcStaking.setRewardPool(totalReward);
  console.log("✅ 奖励池设置：3,000,000 QC");
  
  // 奖励速率：按 12 个月线性释放
  // 3,000,000 QC / (365 * 24 * 60 * 60) ≈ 0.095 QC/秒
  const rewardPerSecond = ethers.parseEther("0.095");
  await qcStaking.setRewardRate(rewardPerSecond);
  console.log("✅ 奖励速率：0.095 QC/秒");
  
  // 设置时间范围（12 个月）
  const startTime = Math.floor(Date.now() / 1000) + 60; // 1 分钟后开始
  const endTime = startTime + (365 * 24 * 60 * 60); // 12 个月
  await qcStaking.setRewardTime(startTime, endTime);
  console.log("✅ 奖励时间：12 个月");
  
  // 添加质押池
  console.log("\n🏊  添加质押池...");
  
  // 池 1: 质押 QC 挖矿（权重 50）
  await qcStaking.addPool(qcTokenAddress, 50, true);
  console.log("✅ 池 1: 质押 QC 挖矿 (APY ~100%)");
  
  // 池 2: 质押 BNB 挖矿（权重 40）
  // BNB 地址（BSC 主网）
  const bnbAddress = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  await qcStaking.addPool(bnbAddress, 40, true);
  console.log("✅ 池 2: 质押 BNB 挖矿 (APY ~80%)");
  
  // 池 3: 质押 QC-BNB LP 挖矿（权重 60）- 需要 PancakeSwap LP 地址
  // 这里先预留，等 PancakeSwap 上线后再添加
  console.log("⏳ 池 3: 质押 QC-BNB LP 挖矿 (待 PancakeSwap 上线后添加)");
  
  // 验证部署
  console.log("\n📊 部署验证...");
  const poolLength = await qcStaking.poolLength();
  console.log("✅ 质押池数量:", poolLength);
  
  const rewardPool = await qcStaking.totalRewardPool();
  console.log("✅ 奖励池总量:", ethers.formatEther(rewardPool), "QC");
  
  const startTimeResult = await qcStaking.startTime();
  const endTimeResult = await qcStaking.endTime();
  console.log("✅ 开始时间:", new Date(Number(startTimeResult) * 1000).toLocaleString());
  console.log("✅ 结束时间:", new Date(Number(endTimeResult) * 1000).toLocaleString());
  
  // 输出摘要
  console.log("\n" + "=".repeat(60));
  console.log("📋 部署摘要");
  console.log("=".repeat(60));
  console.log("网络：BSC 主网");
  console.log("部署者:", deployer.address);
  console.log();
  console.log("合约地址:");
  console.log("  QCStaking:", stakingAddress);
  console.log();
  console.log("奖励配置:");
  console.log("  总奖励池：3,000,000 QC");
  console.log("  奖励速率：0.095 QC/秒");
  console.log("  奖励时间：12 个月");
  console.log();
  console.log("质押池:");
  console.log("  池 0: QC 质押 (权重 50, APY ~100%)");
  console.log("  池 1: BNB 质押 (权重 40, APY ~80%)");
  console.log("  池 2: LP 质押 (待添加)");
  console.log("=".repeat(60));
  
  console.log("\n🎉 部署完成！");
  console.log("\n📱 下一步:");
  console.log("1. 向 QCStaking 合约转账 3,000,000 QC 作为奖励池");
  console.log("2. 等待 PancakeSwap 上线后添加 LP 质押池");
  console.log("3. 编写用户挖矿指南");
  console.log("4. 在官网和社区公布挖矿规则");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
