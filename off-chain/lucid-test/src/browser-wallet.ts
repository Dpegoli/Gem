import { Lucid, Blockfrost } from "lucid-cardano";
import * as dotenv from "dotenv";

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

  try {
    if (typeof window === "undefined") {
      throw new Error("This script needs a browser wallet context.");
    }

    if (!window.cardano || !window.cardano.lace) {
      throw new Error("Lace wallet not found. Please open Lace and enable it.");
    }

    const laceWallet = await window.cardano.lace.enable();
    lucid.selectWallet(laceWallet);

    const address = await lucid.wallet.address();
    
    console.log("🎉 Lace Wallet Connected!");
    console.log("🏦 Wallet Address:", address);
  } catch (error) {
    if (error instanceof Error) {
      console.error("❌ Error:", error.message);
    } else {
      console.error("❌ Unknown error occurred");
    }
  }
}

main().catch(console.error);
