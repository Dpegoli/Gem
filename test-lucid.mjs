import { Blockfrost, Lucid } from "lucid-cardano";
import dotenv from "dotenv";

dotenv.config({ path: "./off-chain/lucid-test/.env" });

console.log("Lucid loaded:", Lucid);

async function main() {
  const apiKey = process.env.BLOCKFROST_API_KEY;

  if (!apiKey) {
    console.error(
      "Missing BLOCKFROST_API_KEY. Copy off-chain/lucid-test/.env.example to off-chain/lucid-test/.env first."
    );
    process.exitCode = 1;
    return;
  }

  const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", apiKey),
    "Preview"
  );

  console.log("Lucid is connected.");
  console.log("Network:", await lucid.network());
}

main().catch(console.error);
