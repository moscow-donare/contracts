import { ethers } from "hardhat";

//TODO: Deploy MockUSDT and CampaignFactory contracts - Test Deployment Script
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("📤 Deploying with getAddress():", deployer.getAddress());

  // 1. Deploy MockUSDT
  const MockUSDT = await ethers.getContractFactory("MockUSDT");
  const usdt = await MockUSDT.deploy();
  await usdt.waitForDeployment();
  console.log("🪙 MockUSDT deployed to:", usdt.getAddress());

  // 2. Deploy CampaignFactory
  const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
  const factory = await CampaignFactory.deploy(usdt.getAddress());
  await factory.waitForDeployment();
  console.log("🏗️ CampaignFactory deployed to:", factory.getAddress());

  // 3. Crear campaña de prueba
  const tx = await factory.createCampaign(
    "Demo campaña Donare",
    "Recaudación para salud",
    "QmEjemploCID",
    ethers.parseUnits("500", 18), // Meta: 500 USDT
    Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60, // +7 días
    "https://donare.org/campaña/demo"
  );
  await tx.wait();
  console.log("🎯 Campaña de prueba creada");
}

main().catch((error) => {
  console.error("❌ Error in deploy:", error);
  process.exitCode = 1;
});
