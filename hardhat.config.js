import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    localhost: { url: "http://127.0.0.1:8545" },
    // Add testnet/mainnet if needed via env keys
  },
};

export default config;
