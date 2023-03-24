import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("AssessmentNFT", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const AssessmentNFT = await ethers.getContractFactory("AssessmentNFT");
    const assessmentNFT = await AssessmentNFT.deploy("https://github.com/");

    return { assessmentNFT, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { assessmentNFT, owner } = await loadFixture(deployFixture);

      expect(await assessmentNFT.owner()).to.equal(owner.address);
    });
  });
});
