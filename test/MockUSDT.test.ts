import { expect } from "chai";
import { ethers } from "hardhat";
import { MockUSDT } from "../typechain-types";

describe("MockUSDT", function () {
  it("should deploy and assign initial balance", async () => {
    const [owner] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MockUSDT");
    const token = await Token.deploy();
    await token.waitForDeployment();

    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(ethers.parseUnits("1000000", 18));
  });
});
