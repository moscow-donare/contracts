// scripts/fundWithMockUSDT.js
const { ethers } = require("hardhat");

async function main() {
  // 👇 Dirección del contrato MockUSDT ya desplegado
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  // 👇 Dirección del destinatario que quieres fondear
  const recipient = '0x6d6C6EA0f463E7B3fA8723A86aF33be8D8967082'; 

  if (!recipient) {
    throw new Error("⚠️ Debes pasar la dirección como argumento. Ej: npx hardhat run scripts/fundWithMockUSDT.js --network localhost 0x1234...");
  }

  // Conectar con el contrato
  const MockUSDT = await ethers.getContractAt("MockUSDT", contractAddress);

  // Definir el monto (100000000 USDT con 18 decimales)
  const decimals = await MockUSDT.decimals();
  const amount = ethers.parseUnits("1000", decimals);

  console.log(`💸 Transfiriendo ${amount} USDT a ${recipient}...`);

  const tx = await MockUSDT.transfer(recipient, amount);
  await tx.wait();

  console.log(`✅ ${recipient} fondeado con 100,000,000 MockUSDT`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
