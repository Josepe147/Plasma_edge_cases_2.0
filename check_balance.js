import { JsonRpcProvider, Wallet, formatEther } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const RPC_URL = process.env.RPC_URL || "https://testnet-rpc.plasma.to";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const provider = new JsonRpcProvider(RPC_URL);
const wallet = new Wallet(PRIVATE_KEY, provider);

console.log("🔍 Checking Deployment Wallet Balance...\n");
console.log("Wallet Address:", wallet.address);

const balance = await provider.getBalance(wallet.address);
console.log("Balance:", formatEther(balance), "XPL");

if (balance > 0n) {
  console.log("\n✅ This wallet has funds!");
  console.log("💡 You can use this wallet to send transactions.");
} else {
  console.log("\n❌ This wallet is empty.");
  console.log("💡 You need to get testnet XPL from a faucet.");
}
