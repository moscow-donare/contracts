import { expect } from "chai";
import { ethers } from "hardhat";
import { Campaign, MockUSDT } from "../typechain-types";

describe("Campaign", function () {
  let usdt: MockUSDT;
  let campaign: Campaign;
  let owner: any;
  let user: any;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    const MockUSDT = await ethers.getContractFactory("MockUSDT");
    usdt = (await MockUSDT.deploy()) as MockUSDT;
    await usdt.waitForDeployment();

    const Campaign = await ethers.getContractFactory("Campaign");
    campaign = await Campaign.deploy(
      owner.getAddress(),
      user.getAddress(),
      0,
      "Test Title",
      "Test Description",
      "CID123",
      ethers.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60,
      "https://donare.test",
      1,
      usdt.getAddress()
    );
    await campaign.waitForDeployment();

    await usdt.transfer(user.getAddress(), ethers.parseUnits("1000", 18));
  });

  it("should allow donation when campaign is active", async () => {
    await campaign.connect(owner).approveCampaign("Validada");

    await usdt.connect(user).approve(campaign.getAddress(), ethers.parseUnits("50", 18));
    await expect(campaign.connect(user).donate(ethers.parseUnits("50", 18)))
      .to.emit(campaign, "Donated")
      .withArgs(user.getAddress(), ethers.parseUnits("50", 18));
  });

  it("should not allow donation if not active", async () => {
    await usdt.connect(user).approve(campaign.getAddress(), ethers.parseUnits("10", 18));
    await expect(campaign.connect(user).donate(ethers.parseUnits("10", 18))).to.be.revertedWith(
      "La campania no esta activa"
    );
  });

  it("should return to InReview on edit by creator", async () => {
    await campaign.connect(owner).approveCampaign("Validada");

    await campaign.connect(user).editCampaign(
      "New Title",
      "New Description",
      "NewCID",
      ethers.parseUnits("200", 18),
      Math.floor(Date.now() / 1000) + 10 * 24 * 60 * 60,
      "https://updated.url",
      "Actualizacion del contenido"
    );

    const status = await campaign.status();
    expect(status).to.equal(0); // InReview
  });
});
