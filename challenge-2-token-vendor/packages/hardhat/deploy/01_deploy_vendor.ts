import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "Vendor" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const deployVendor: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  // Deploy Vendor
  
  const { deployer } = await hre.getNamedAccounts();
  console.log("deployer", deployer);

  const deployerBalance = await hre.ethers.provider.getBalance(deployer);
  console.log("deployer balance:", hre.ethers.formatEther(deployerBalance), "ETH");

  const { deploy } = hre.deployments;
  const yourToken = await hre.ethers.getContract<Contract>("YourToken", deployer);
  
  const yourTokenAddress = await yourToken.getAddress();
  console.log("yourTokenAddress", yourTokenAddress);
  await deploy("Vendor", {
    from: deployer,
    // Contract constructor arguments
    args: [yourTokenAddress],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });
  const vendor = await hre.ethers.getContract<Contract>("Vendor", deployer);
  const vendorAddress = await vendor.getAddress();
  console.log("vendorAddress", vendorAddress);
  // Transfer tokens to Vendor

  console.log("Vendor balance before transfer:", await hre.ethers.provider.getBalance(vendorAddress), "Wei");
  console.log("YourToken balance of Vendor before transfer:", await yourToken.balanceOf(vendorAddress));
  console.log("YourToken balance of deployer before transfer:", await yourToken.balanceOf(deployer));
  
  
  // Transfer tokens to Vendor
  console.log(">>> transferring 1000 tokens from deployer to Vendor");
  await yourToken.transfer(vendorAddress, hre.ethers.parseEther("1000"));


  console.log("Vendor balance after transfer:", await hre.ethers.provider.getBalance(vendorAddress), "Wei");
  console.log("YourToken balance of Vendor after transfer:", await yourToken.balanceOf(vendorAddress));
  console.log("YourToken balance of deployer after transfer:", await yourToken.balanceOf(deployer));

  // Transfer contract ownership to your frontend address
  
  const frontendAddress = "0x235963790FcB341426BB70bd1cA2A8eF3406B451";
  console.log("transferring ownership to "+frontendAddress);
  await vendor.transferOwnership(frontendAddress);
  
};

export default deployVendor;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags Vendor
deployVendor.tags = ["Vendor"];
