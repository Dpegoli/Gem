import { Lucid, Blockfrost } from "lucid-cardano";
import * as dotenv from "dotenv";
import * as fs from "fs";

dotenv.config();

const apiKey = process.env.BLOCKFROST_API_KEY;
console.log("✅ Lucid loaded:", Lucid);
console.log("🔑 Blockfrost API Key Loaded:", apiKey ? "Yes" : "No");

async function main() {
  if (!apiKey) {
    console.error("❌ Blockfrost API Key is missing. Check your .env file.");
    console.error("Copy .env.example to .env and add your Preview API key.");
    return;
  }

  const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", apiKey),
    "Preview"
  );
  console.log("✅ Lucid is connected to Blockfrost!");

  // 🔹 Generate new private key
  const privateKey = lucid.utils.generatePrivateKey();
  console.log("🔑 New Private Key Generated!");

  // 🔹 Derive public address from private key
  lucid.selectWalletFromPrivateKey(privateKey);
  const address = await lucid.wallet.address();
  console.log("🏦 Wallet Address Generated:", address);

  // 🔹 Save wallet to file
  fs.writeFileSync(
    "wallet.json",
    JSON.stringify({ privateKey, address }, null, 2)
  );
  console.log("💾 Wallet Saved to wallet.json");
  console.log("🔒 Keep wallet.json private and never commit it.");
}

main().catch(console.error);
