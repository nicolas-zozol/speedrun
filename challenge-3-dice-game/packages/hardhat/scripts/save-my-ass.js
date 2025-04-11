const fs = require("fs");
const ethers = require("ethers");

// Paste your JSON here as a raw string
const keystore = `{"address":"c1894f79bbab1e2a8ac14e764552795e5e37452e","id":"f39afc42-ac12-40b2-be8d-f6ff0b3d2fcb","version":3,"Crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"981d532155ebb85138016a048d96797a"},"ciphertext":"30c4b93948bdec126603e16b7a09df6149359c979c44ede0048ddb2e7b7ddcfe","kdf":"scrypt","kdfparams":{"salt":"466f622eae9096124abd40010a92e756ab3e0723e15709125471e59fe8a5b400","n":131072,"dklen":32,"p":1,"r":8},"mac":"9a9a5da8778f11c71ff75c9599f5ebe5473f329d79a8199a2d7c8516473ff8d1"},"x-ethers":{"client":"ethers/6.13.6","gethFilename":"UTC--2025-04-09T13-49-31.0Z--c1894f79bbab1e2a8ac14e764552795e5e37452e","path":"m/44'/60'/0'/0/0","locale":"en","mnemonicCounter":"515bffdb889eb1d88280b0c439a0c460","mnemonicCiphertext":"c230a69f6776d53fed02e342221055a3","version":"0.1"}}`;

const password = ""; // Replace with the one you used during `yarn generate`

async function main() {
  try {
    const wallet = await ethers.Wallet.fromEncryptedJson(keystore, password);
    console.log("✅ Private Key:", wallet.privateKey);
    console.log("✅ Address:", wallet.address);
  } catch (err) {
    console.error("❌ Error decrypting keystore:", err.message);
  }
}

main();
