import { Lucid, Blockfrost } from "lucid-cardano";
import dotenv from "dotenv";

dotenv.config();

const apiKey = process.env.BLOCKFROST_API_KEY;
console.log(" Lucid loaded:", Lucid);
console.log(" Blockfrost API Key Loaded:", apiKey ? "Yes" : "No");

async function main() {
  if (!apiKey) {
    console.error(" Blockfrost API Key is missing. Check your .env file.");
    return;
  }

  const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", apiKey),
    "Preview"
  );
  console.log("Lucid is connected to Blockfrost!");

  try {
    // 🔹 Select Lace Wallet (Modify this line to support Lace)
    await lucid.selectWalletFrom({ name: "lace" });

    // 🔹 Get Wallet Address
    const address = await lucid.wallet.address();
    
    console.log(" Lace Wallet Connected!");
    console.log(" Wallet Address:", address);
  } catch (error) {
    console.error(" No Lace wallet found. Please open Lace and enable it.");
  }
}

main().catch(console.error);