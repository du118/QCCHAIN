const hre = require("hardhat");

async function main() {
  console.log("🚀 QC Chain 合约部署开始...\n");
  
  // 获取部署者账户
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 部署者地址:", deployer.address);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 账户余额:", hre.ethers.formatEther(balance), "ETH\n");
  
  // 配置代币分配地址（实际部署时替换为真实地址）
  const config = {
    founder: process.env.FOUNDER_ADDRESS || deployer.address,
    team: process.env.TEAM_ADDRESS || deployer.address,
    mining: process.env.MINING_ADDRESS || deployer.address,
    ecosystem: process.env.ECOSYSTEM_ADDRESS || deployer.address,
    marketing: process.env.MARKETING_ADDRESS || deployer.address,
    community: process.env.COMMUNITY_ADDRESS || deployer.address,
    maintenance: process.env.MAINTENANCE_ADDRESS || deployer.address,
  };
  
  console.log("📊 代币分配地址:");
  console.log("  创始人:", config.founder);
  console.log("  团队:", config.team);
  console.log("  挖矿:", config.mining);
  console.log("  生态:", config.ecosystem);
  console.log("  市场:", config.marketing);
  console.log("  社区:", config.community);
  console.log("  维护:", config.maintenance);
  console.log();
  
  // 1. 部署代币合约
  console.log("🪙 部署 QCToken 合约...");
  const QCToken = await hre.ethers.getContractFactory("QCToken");
  const qcToken = await QCToken.deploy(
    config.founder,
    config.team,
    config.mining,
    config.ecosystem,
    config.marketing,
    config.community,
    config.maintenance
  );
  await qcToken.waitForDeployment();
  const qcTokenAddress = await qcToken.getAddress();
  console.log("✅ QCToken 部署成功:", qcTokenAddress);
  
  // 2. 部署代币解锁合约
  console.log("\n🔒 部署 VestingSchedule 合约...");
  const VestingSchedule = await hre.ethers.getContractFactory("VestingSchedule");
  const vestingSchedule = await VestingSchedule.deploy(qcTokenAddress);
  await vestingSchedule.waitForDeployment();
  const vestingAddress = await vestingSchedule.getAddress();
  console.log("✅ VestingSchedule 部署成功:", vestingAddress);
  
  // 3. 部署挖矿奖励合约
  console.log("\n⛏️  部署 MiningReward 合约...");
  const MiningReward = await hre.ethers.getContractFactory("MiningReward");
  const miningReward = await MiningReward.deploy(qcTokenAddress);
  await miningReward.waitForDeployment();
  const miningAddress = await miningReward.getAddress();
  console.log("✅ MiningReward 部署成功:", miningAddress);
  
  // 4. 部署代码贡献奖励合约
  console.log("\n💻 部署 CodeContribution 合约...");
  const CodeContribution = await hre.ethers.getContractFactory("CodeContribution");
  const codeContribution = await CodeContribution.deploy(qcTokenAddress);
  await codeContribution.waitForDeployment();
  const contributionAddress = await codeContribution.getAddress();
  console.log("✅ CodeContribution 部署成功:", contributionAddress);
  
  // 5. 执行代币分配
  console.log("\n📦 执行代币分配...");
  const tx1 = await qcToken.executeDistribution();
  await tx1.wait();
  console.log("✅ 代币分配完成");
  
  // 6. 配置挖矿奖励合约
  console.log("\n⚙️  配置挖矿奖励...");
  const startBlock = (await hre.ethers.provider.getBlockNumber()) + 100; // 100 个区块后开始
  const tx2 = await miningReward.startMining(startBlock);
  await tx2.wait();
  console.log("✅ 挖矿配置完成，开始区块:", startBlock);
  
  // 7. 转账代币到各合约
  console.log("\n💸 向合约转账...");
  
  // 向挖矿合约转账（540 万 QC）
  const miningAmount = await miningReward.MAX_MINING_REWARD();
  const tx3 = await qcToken.transfer(miningAddress, miningAmount);
  await tx3.wait();
  console.log("✅ 向 MiningReward 转账:", hre.ethers.formatEther(miningAmount), "QC");
  
  // 向代码贡献合约转账（90 万 QC）
  const contributionAmount = hre.ethers.parseEther("900000");
  const tx4 = await qcToken.transfer(contributionAddress, contributionAmount);
  await tx4.wait();
  console.log("✅ 向 CodeContribution 转账:", hre.ethers.formatEther(contributionAmount), "QC");
  
  // 输出部署摘要
  console.log("\n" + "=".repeat(60));
  console.log("📋 部署摘要");
  console.log("=".repeat(60));
  console.log("网络:", hre.network.name);
  console.log("部署者:", deployer.address);
  console.log();
  console.log("合约地址:");
  console.log("  QCToken:          ", qcTokenAddress);
  console.log("  VestingSchedule:  ", vestingAddress);
  console.log("  MiningReward:     ", miningAddress);
  console.log("  CodeContribution: ", contributionAddress);
  console.log();
  console.log("代币信息:");
  console.log("  名称：Quantum Coin");
  console.log("  符号：QC");
  console.log("  总量：18,000,000 QC");
  console.log("  小数：18");
  console.log();
  console.log("挖矿信息:");
  console.log("  初始奖励：2 QC/区块");
  console.log("  减半周期：210,000 区块");
  console.log("  总奖励：5,400,000 QC");
  console.log("  开始区块:", startBlock);
  console.log("=".repeat(60));
  
  // 验证合约（如果配置了 API Key）
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("\n🔍 开始验证合约...");
    try {
      await hre.run("verify:verify", {
        address: qcTokenAddress,
        constructorArguments: [
          config.founder,
          config.team,
          config.mining,
          config.ecosystem,
          config.marketing,
          config.community,
          config.maintenance,
        ],
      });
      console.log("✅ QCToken 验证成功");
      
      await hre.run("verify:verify", {
        address: vestingAddress,
        constructorArguments: [qcTokenAddress],
      });
      console.log("✅ VestingSchedule 验证成功");
      
      await hre.run("verify:verify", {
        address: miningAddress,
        constructorArguments: [qcTokenAddress],
      });
      console.log("✅ MiningReward 验证成功");
      
      await hre.run("verify:verify", {
        address: contributionAddress,
        constructorArguments: [qcTokenAddress],
      });
      console.log("✅ CodeContribution 验证成功");
    } catch (error) {
      console.log("⚠️  合约验证失败（可能已验证）:", error.message);
    }
  }
  
  console.log("\n🎉 部署完成！");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
