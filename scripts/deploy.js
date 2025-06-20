const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
  const marketplace = await NFTMarketplace.deploy(deployer.address);

  await marketplace.deployed();

  console.log(`NFTMarketplace deployed to: ${marketplace.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
