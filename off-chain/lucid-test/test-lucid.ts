import { Lucid } from "lucid-cardano";
import { Blockfrost } from "lucid-cardano";
import dotenv from "dotenv";

dotenv.config(); //  Load .env variables

const apiKey = process.env.BLOCKFROST_API_KEY; //  Use API key from .env

console.log("Lucid loaded:", Lucid);
console.log(" Blockfrost API Key Loaded:", apiKey ? "Yes" : "No");

async function main() {
  if (!apiKey) {
    console.error(" Blockfrost API Key is missing. Check your .env file.");
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

  // ✅ Check if the browser has a Cardano wallet
  const walletName = "nami"; // Change to "eternl" if using Eternl
  if (typeof window !== "undefined" && window.cardano) {
    console.log("🔗 Connecting to wallet:", walletName);
    await lucid.selectWalletFromExtension(walletName);
  } else {
    console.error("No wallet extension found. Open Nami or Eternl and enable it.");
    return;
  }

  // ✅ Get and display the wallet address
  const walletAddress = await lucid.wallet.address();
  console.log("🏦 Connected Wallet Address:", walletAddress);
}

// ✅ Run the function
main().catch(console.error);