import { ethers, network } from "hardhat";

async function main() {
  const walletAddress = "0xb542fB5E0345F4E55C6D23f551EE756cc7f6B3c5"; // acá pegás la address 
  const balance = ethers.parseEther("100000"); // cuánto ETH querés setear

  await network.provider.send("hardhat_setBalance", [
    walletAddress,
    ethers.toBeHex(balance),
  ]);

  const newBalance = await ethers.provider.getBalance(walletAddress);
  console.log(`✅ Balance seteado: ${ethers.formatEther(newBalance)} ETH`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
