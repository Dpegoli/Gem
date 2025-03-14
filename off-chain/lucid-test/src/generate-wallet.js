"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const lucid_cardano_1 = require("lucid-cardano");
const dotenv = __importStar(require("dotenv"));
const fs = __importStar(require("fs"));
dotenv.config();
const apiKey = process.env.BLOCKFROST_API_KEY;
console.log("✅ Lucid loaded:", lucid_cardano_1.Lucid);
console.log("🔑 Blockfrost API Key Loaded:", apiKey ? "Yes" : "No");
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        if (!apiKey) {
            console.error("❌ Blockfrost API Key is missing. Check your .env file.");
            return;
        }
        const lucid = yield lucid_cardano_1.Lucid.new(new lucid_cardano_1.Blockfrost("https://cardano-preview.blockfrost.io/api/v0", apiKey), "Preview");
        console.log("✅ Lucid is connected to Blockfrost!");
        // 🔹 Generate new private key
        const privateKey = lucid.utils.generatePrivateKey();
        console.log("🔑 New Private Key Generated!");
        // 🔹 Derive public address from private key
        lucid.selectWalletFromPrivateKey(privateKey);
        const address = yield lucid.wallet.address();
        console.log("🏦 Wallet Address Generated:", address);
        // 🔹 Save wallet to file
        fs.writeFileSync("wallet.json", JSON.stringify({ privateKey, address }, null, 2));
        console.log("💾 Wallet Saved to wallet.json");
    });
}
main().catch(console.error);
