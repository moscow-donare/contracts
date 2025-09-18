import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    // configuración para nodo local de prueba
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
     // Red de Amoy (Polygon testnet)
    amoy: {
      url: "https://rpc-amoy.polygon.technology", // RPC oficial de Amoy
      chainId: 80002,
      accounts: process.env.PRIVATE_KEY
        ? [process.env.PRIVATE_KEY]
        : [], // tu private key en .env sin "0x"
    },
  },
};

export default config;
