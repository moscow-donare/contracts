import { expect } from "chai";
import { ethers } from "hardhat";
import { CampaignFactory, MockUSDT } from "../typechain-types";

describe("CampaignFactory", function () {
  let factory: CampaignFactory;
  let usdt: MockUSDT;
  let owner: any;
  let user: any;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    const MockUSDT = await ethers.getContractFactory("MockUSDT");
    usdt = await MockUSDT.deploy();
    usdt.waitForDeployment();

    const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
    factory = await CampaignFactory.deploy(usdt.getAddress());
    await factory.waitForDeployment();
  });

  it("should create a new campaign", async () => {
    const tx = await factory.connect(user).createCampaign(
      user.address, // <-- address creator
      "Título prueba",
      "Descripcion",
      "CID123",
      ethers.parseUnits("500", 18),
      Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60,
      "https://donare.test",
      1
    );

    await tx.wait();

    const all = await factory.all();
    expect(all.length).to.equal(1);
  });

  it("should block creating two active campaigns", async () => {
    await factory.connect(user).createCampaign(
      user.address,
      "Primera",
      "Desc",
      "CID",
      ethers.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 100000,
      "https://url",
      1
    );

    await expect(
      factory.connect(user).createCampaign(
        user.address,
        "Segunda",
        "Desc",
        "CID",
        ethers.parseUnits("100", 18),
        Math.floor(Date.now() / 1000) + 100000,
        "https://url",
        1
      )
    ).to.be.revertedWith("Ya tienes una campania activa o pendiente");
  });
});
