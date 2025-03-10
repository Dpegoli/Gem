import { Lucid } from "lucid-cardano"; console.log("Lucid loaded:", Lucid);


async function main() {
  const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preprod.blockfrost.io/api/v0", "previewmYOKn2ziEcTZw4GFtQo3qGwNjRfCiAIW"),
    "Prepod"
  );

  console.log("✅ Lucid is connected!");
  console.log("🌐 Network:", await lucid.network());
}

main().catch(console.error);