const { expect } = require("chai");
const { ethers } = require("hardhat");
const tokenJson = require("../artifacts/contracts/ERC20.sol/MCSToken.json");

describe("MShop", function () {
  let owner, buyer, shop, erc20;

  beforeEach(async () => {
    [owner, buyer] = await ethers.getSigners();

    const MShop = await ethers.getContractFactory("MShop", owner);
    shop = await MShop.deploy();
    await shop.deployed();

    erc20 = new ethers.Contract(shop.token(), tokenJson.abi, owner);
  });

  it("Should have an owner and a token", async () => {
    expect(await shop.owner()).to.eq(owner.address);
    expect(await shop.token()).to.be.properAddress;
  });

  it("Allows to buy", async () => {
    const tokensAmount = 3;

    const txData = {
      value: tokensAmount,
      to: shop.address,
    };

    const tx = await buyer.sendTransaction(txData);
    await tx.wait();

    expect(await erc20.balanceOf(buyer.address)).to.eq(tokensAmount);
    await expect(tx).to.changeEtherBalance(shop, tokensAmount);
    await expect(tx)
      .to.emit(shop, "Bought")
      .withArgs(tokensAmount, buyer.address);
  });

  it("Allows to sell", async () => {
    const tx = await buyer.sendTransaction({
      value: 10,
      to: shop.address,
    });
    await tx.wait();

    const approval = await erc20.connect(buyer).approve(shop.address, 2);
    await approval.wait();

    const sellTx = await shop.connect(buyer).sell(2);
    await sellTx.wait();

    expect(await erc20.balanceOf(buyer.address)).to.eq(8);
    await expect(sellTx).to.changeEtherBalance(shop, -2);
    await expect(sellTx).to.emit(shop, "Sold").withArgs(2, buyer.address);
  });
});
