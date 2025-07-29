import { ethers } from "hardhat";

//TODO: Deploy MockUSDT and CampaignFactory contracts - Test Deployment Script
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("📤 Deploying with getAddress():", deployer.getAddress());

  // 1. Deploy MockUSDT
  const MockUSDT = await ethers.getContractFactory("MockUSDT");
  const usdt = await MockUSDT.deploy();
  await usdt.waitForDeployment();
  console.log("🪙 MockUSDT deployed to:", await usdt.getAddress());

  // 2. Deploy CampaignFactory
  const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
  const factory = await CampaignFactory.deploy(usdt.getAddress());
  await factory.waitForDeployment();
  console.log("🏗️ CampaignFactory deployed to:", await factory.getAddress());
}

main().catch((error) => {
  console.error("❌ Error in deploy:", error);
  process.exitCode = 1;
});
