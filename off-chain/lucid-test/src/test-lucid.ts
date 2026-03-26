import { Blockfrost, Lucid } from "lucid-cardano";
import * as dotenv from "dotenv";

dotenv.config(); //  Load .env variables

const apiKey = process.env.BLOCKFROST_API_KEY; //  Use API key from .env

console.log("Lucid loaded:", Lucid);
console.log(" Blockfrost API Key Loaded:", apiKey ? "Yes" : "No");

async function main() {
  if (!apiKey) {
    console.error(" Blockfrost API Key is missing. Check your .env file.");
    console.error(" Copy .env.example to .env and add your Preview API key.");
    return;
  }

  // ✅ Ensure Blockfrost is using the Preview Network
  const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", apiKey),
    "Preview"
  );

  console.log(" Lucid is connected!");
  
  // ✅ Fetch network parameters to confirm connection
  const protocolParams = await lucid.provider.getProtocolParameters();
  console.log(" Blockfrost is connected and responding!");
  console.log(" Protocol Parameters:", protocolParams);
  console.log(" This script only verifies Lucid + Blockfrost connectivity.");
  console.log(" Use src/browser-wallet.ts in a browser-capable context for wallet access.");
}

// ✅ Run the function
main().catch(console.error);
