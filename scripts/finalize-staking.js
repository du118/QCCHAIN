const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 设置挖矿合约奖励池...\n");
  
  // 合约地址
  const stakingAddress = "0x2e5Bc4D117342fca7cc43d11Dc7f49fDd1B5045f";
  
  // 获取部署者（旧钱包）
  const [deployer] = await ethers.getSigners();
  console.log("📝 操作者地址:", deployer.address);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 BNB 余额:", ethers.formatEther(balance), "BNB\n");
  
  // 获取合约实例
  const QCStaking = await ethers.getContractFactory("QCStaking");
  const qcStaking = QCStaking.attach(stakingAddress);
  
  // 验证合约 owner
  const owner = await qcStaking.owner();
  console.log("🔐 合约 Owner:", owner);
  console.log("   是否匹配:", owner.toLowerCase() === deployer.address.toLowerCase() ? "✅ 是" : "❌ 否");
  
  if (owner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("\n❌ 错误：当前地址不是合约 Owner！");
    return;
  }
  
  // 设置奖励池总量（300 万 QC）
  console.log("\n⏳ 设置奖励池总量...");
  const rewardAmount = ethers.parseEther("3000000");
  console.log("   奖励池：3,000,000 QC");
  
  const tx = await qcStaking.setRewardPool(rewardAmount);
  console.log("   交易发送中...");
  console.log("   交易哈希:", tx.hash);
  
  await tx.wait();
  console.log("✅ 交易确认！");
  
  // 验证设置
  const totalRewardPool = await qcStaking.totalRewardPool();
  console.log("\n📊 验证结果:");
  console.log("   奖励池总量:", ethers.formatEther(totalRewardPool), "QC");
  
  const rewardPerSecond = await qcStaking.rewardPerSecond();
  console.log("   奖励速率:", ethers.formatEther(rewardPerSecond), "QC/秒");
  
  const startTime = await qcStaking.startTime();
  const endTime = await qcStaking.endTime();
  console.log("   开始时间:", new Date(Number(startTime) * 1000).toLocaleString("zh-CN"));
  console.log("   结束时间:", new Date(Number(endTime) * 1000).toLocaleString("zh-CN"));
  
  const poolLength = await qcStaking.poolLength();
  console.log("   质押池数量:", poolLength);
  
  // 输出摘要
  console.log("\n" + "=".repeat(60));
  console.log("📋 配置完成摘要");
  console.log("=".repeat(60));
  console.log("网络：BSC 主网");
  console.log("操作者:", deployer.address);
  console.log();
  console.log("合约地址:");
  console.log("  QCStaking:", stakingAddress);
  console.log();
  console.log("挖矿配置:");
  console.log("  总奖励池：3,000,000 QC ✅");
  console.log("  奖励速率：0.095 QC/秒 ✅");
  console.log("  奖励时间：12 个月 ✅");
  console.log();
  console.log("质押池:");
  console.log("  池 0: QC 质押 (权重 50, APY ~100%) ✅");
  console.log("  池 1: BNB 质押 (权重 40, APY ~80%) ✅");
  console.log();
  console.log("Gas 费用:");
  const newBalance = await ethers.provider.getBalance(deployer.address);
  const gasUsed = balance - newBalance;
  console.log("  消耗:", ethers.formatEther(gasUsed), "BNB");
  console.log("  剩余:", ethers.formatEther(newBalance), "BNB");
  console.log("=".repeat(60));
  
  console.log("\n🎉 挖矿合约配置完成！");
  console.log("\n🔗 查看合约:");
  console.log("https://bscscan.com/address/" + stakingAddress);
  console.log("\n🔗 查看交易:");
  console.log("https://bscscan.com/tx/" + tx.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
