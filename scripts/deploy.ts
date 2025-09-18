import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("📤 Deploying contracts with:", deployer.address);

  // Balance antes del deploy
  let balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 Balance before:", ethers.formatEther(balance), "ETH");

  // 1. Deploy MockUSDT
  const MockUSDT = await ethers.getContractFactory("MockUSDT");
  const usdt = await MockUSDT.deploy();
  const usdtTx = usdt.deploymentTransaction();
  if (usdtTx) {
    console.log("🪙 MockUSDT tx hash:", usdtTx.hash);
    const receipt = await usdtTx.wait();
    console.log("⛽ Gas used (MockUSDT):", receipt?.gasUsed.toString());
  }
  console.log("🪙 MockUSDT deployed to:", await usdt.getAddress());

  // 2. Deploy CampaignFactory
  const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
  const factory = await CampaignFactory.deploy(await usdt.getAddress());
  const factoryTx = factory.deploymentTransaction();
  if (factoryTx) {
    console.log("🏗️ CampaignFactory tx hash:", factoryTx.hash);
    const receipt = await factoryTx.wait();
    console.log("⛽ Gas used (CampaignFactory):", receipt?.gasUsed.toString());
  }
  console.log("🏗️ CampaignFactory deployed to:", await factory.getAddress());

  // Balance después del deploy
  balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 Balance after:", ethers.formatEther(balance), "ETH");
}

main().catch((error) => {
  console.error("❌ Error in deploy:", error);
  process.exitCode = 1;
});
