const hre = require("hardhat");

// Returns the Ether balance of a given address.
async function getBalance(address) {
  const balanceBigInt = await hre.ethers.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

// Logs the Ether balances for a list of addresses.
async function printBalances(addresses) {
  let idx = 0;
  for (const address of addresses) {
    console.log(`Address ${idx} balance: `, await getBalance(address));
    idx++;
  }
}

// Logs the memos stored on-chain
async function printMemos(memos) {
  for (const memo of memos) {
    const timestamp = memo.timestamp;
    const tipper = memo.name;
    const tipperAddress = memo.from;
    const message = memo.message;
    console.log(
      `At ${timestamp}, ${tipper} (${tipperAddress}) said: "${message}"`
    );
  }
}

async function main() {
  // Get the example accounts we'll be working with.
  const [owner, tipper, tipper2, tipper3] = await hre.ethers.getSigners();

  // We get the contract to deploy.
  const GetMemo = await hre.ethers.getContractFactory("GetMemo");
  const getMemo = await GetMemo.deploy();

  // Deploy the contract.
  await getMemo.deployed();
  console.log("Memo contract deployed to:", getMemo.address);

  // Check balances before
  const addresses = [owner.address, tipper.address, getMemo.address];
  console.log("== start ==");
  await printBalances(addresses);

  // Buy the owner a memo
  const tip = { value: hre.ethers.utils.parseEther("1") };
  await getMemo.connect(tipper).buyMemo("ASHOK", "You are the best", tip);
  await getMemo.connect(tipper2).buyMemo("JUkie", "Nice work!", tip);
  await getMemo.connect(tipper3).buyMemo("lolii", "WAGMI!", tip);

  // Check balances
  console.log("== MEMOSBALANCE ==");
  await printBalances(addresses);

  // Withdraw.
  await getMemo.connect(owner).withdrawTips();

  // Check balances after withdrawal.
  console.log("== withdrawETH ==");
  await printBalances(addresses);

  // Check out the memos.
  console.log("== memos ==");
  const memos = await getMemo.getMemos();
  printMemos(memos);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
