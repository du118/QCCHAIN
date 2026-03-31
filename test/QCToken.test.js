const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("QCToken", function () {
  let qcToken;
  let owner;
  let founder;
  let team;
  let mining;
  let ecosystem;
  let marketing;
  let community;
  let maintenance;
  
  const MAX_SUPPLY = ethers.parseEther("18000000"); // 1800 万 QC
  
  beforeEach(async function () {
    [owner, founder, team, mining, ecosystem, marketing, community, maintenance] = await ethers.getSigners();
    
    const QCToken = await ethers.getContractFactory("QCToken");
    qcToken = await QCToken.deploy(
      founder.address,
      team.address,
      mining.address,
      ecosystem.address,
      marketing.address,
      community.address,
      maintenance.address
    );
    await qcToken.waitForDeployment();
  });
  
  it("应该正确设置代币名称和符号", async function () {
    expect(await qcToken.name()).to.equal("Quantum Coin");
    expect(await qcToken.symbol()).to.equal("QC");
    expect(await qcToken.decimals()).to.equal(18);
  });
  
  it("应该正确设置总供应量", async function () {
    expect(await qcToken.maxSupply()).to.equal(MAX_SUPPLY);
    expect(await qcToken.totalSupply()).to.equal(MAX_SUPPLY);
  });
  
  it("应该正确设置代币分配地址", async function () {
    expect(await qcToken.founderAddress()).to.equal(founder.address);
    expect(await qcToken.teamAddress()).to.equal(team.address);
    expect(await qcToken.miningAddress()).to.equal(mining.address);
    expect(await qcToken.ecosystemAddress()).to.equal(ecosystem.address);
    expect(await qcToken.marketingAddress()).to.equal(marketing.address);
    expect(await qcToken.communityAddress()).to.equal(community.address);
    expect(await qcToken.maintenanceAddress()).to.equal(maintenance.address);
  });
  
  it("应该正确计算代币分配数量", async function () {
    const founderAmt = await qcToken.founderAmount();
    const teamAmt = await qcToken.teamAmount();
    const miningAmt = await qcToken.miningAmount();
    const ecosystemAmt = await qcToken.ecosystemAmount();
    const marketingAmt = await qcToken.marketingAmount();
    const communityAmt = await qcToken.communityAmount();
    const maintenanceAmt = await qcToken.maintenanceAmount();
    
    expect(founderAmt).to.equal(ethers.parseEther("6300000")); // 35%
    expect(teamAmt).to.equal(ethers.parseEther("2700000"));   // 15%
    expect(miningAmt).to.equal(ethers.parseEther("5400000")); // 30%
    expect(ecosystemAmt).to.equal(ethers.parseEther("900000")); // 5%
    expect(marketingAmt).to.equal(ethers.parseEther("900000")); // 5%
    expect(communityAmt).to.equal(ethers.parseEther("900000")); // 5%
    expect(maintenanceAmt).to.equal(ethers.parseEther("900000")); // 5%
  });
  
  it("应该只有 owner 可以执行代币分配", async function () {
    await expect(qcToken.connect(founder).executeDistribution())
      .to.be.revertedWith("Ownable: caller is not the owner");
  });
  
  it("应该成功执行代币分配", async function () {
    const tx = await qcToken.executeDistribution();
    await tx.wait();
    
    expect(await qcToken.distributionCompleted()).to.be.true;
    
    // 验证各地址余额
    expect(await qcToken.balanceOf(founder.address)).to.equal(ethers.parseEther("6300000"));
    expect(await qcToken.balanceOf(team.address)).to.equal(ethers.parseEther("2700000"));
    expect(await qcToken.balanceOf(mining.address)).to.equal(ethers.parseEther("5400000"));
    expect(await qcToken.balanceOf(ecosystem.address)).to.equal(ethers.parseEther("900000"));
    expect(await qcToken.balanceOf(marketing.address)).to.equal(ethers.parseEther("900000"));
    expect(await qcToken.balanceOf(community.address)).to.equal(ethers.parseEther("900000"));
    expect(await qcToken.balanceOf(maintenance.address)).to.equal(ethers.parseEther("900000"));
  });
  
  it("应该不能重复执行代币分配", async function () {
    await qcToken.executeDistribution();
    await expect(qcToken.executeDistribution())
      .to.be.revertedWith("Distribution already completed");
  });
  
  it("应该支持代币燃烧", async function () {
    await qcToken.executeDistribution();
    
    const burnAmount = ethers.parseEther("1000");
    await qcToken.connect(founder).burn(burnAmount);
    
    expect(await qcToken.balanceOf(founder.address)).to.equal(
      ethers.parseEther("6300000") - burnAmount
    );
    expect(await qcToken.totalSupply()).to.equal(MAX_SUPPLY - burnAmount);
  });
  
  it("应该支持 owner 暂停和恢复", async function () {
    await qcToken.executeDistribution();
    
    // 暂停
    await qcToken.pause();
    await expect(qcToken.connect(founder).transfer(team.address, ethers.parseEther("100")))
      .to.be.reverted;
    
    // 恢复
    await qcToken.unpause();
    await expect(qcToken.connect(founder).transfer(team.address, ethers.parseEther("100")))
      .to.not.be.reverted;
  });
});
