import { ethers } from "hardhat";

async function main() {
  const AssessmentNFT = await ethers.getContractFactory("AssessmentNFT");
  const assessmentNFT = await AssessmentNFT.deploy("https://github.com/");
  await assessmentNFT.deployed();

  console.log(`AssessmentNFT deployed to ${assessmentNFT.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
