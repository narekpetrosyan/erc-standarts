const hre = require("hardhat");

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const MShop = await hre.ethers.getContractFactory("MShop", signer);
  const mshop = await MShop.deploy();

  await mshop.deployed();

  console.log("MShop deployed: ", mshop.address);
  console.log("Token deployed: ", await mshop.token());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
