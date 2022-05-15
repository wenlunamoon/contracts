const { ethers, upgrades } = require("hardhat");

const treasury = "0xFb08de74D3DC381d2130e8885BdaD4e558b24145";
const token = "0x1Cf87CF9e01b4497674570BAA037844A3816B7A9";

async function main() {
  // const Token = await ethers.getContractFactory("WenLunaMoon");
  // const token = await upgrades.deployProxy(Token, []);
  // await token.deployed();
  // console.log("Token deployed to:", token.address);
  const Presale = await ethers.getContractFactory("Presale");
  const presale = await Presale.deploy(treasury, token);
  await presale.deployed();
  console.log("Presale deployed to:", presale.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
