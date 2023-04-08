const hre = require("hardhat");

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const ERC20 = await hre.ethers.getContractFactory("MShop", signer);
  const erc20 = await ERC20.deploy();

  await erc20.deployed();

  console.log(erc20.address);
  console.log(await erc20.token());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
