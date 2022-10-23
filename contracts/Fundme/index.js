import { ethers } from "./ethers.js";
import { abi, contractAddress } from "./constants.js";
// import { ethers } from "https://cdn.ethers.io/lib/ethers-5.2.esm.min.js"
const icodiv = document.getElementsByClassName("icon");
const connectbtn = document.getElementById("buttn");
const fundbtn = document.getElementById("fnd");
const Balancebtn = document.getElementById("blncefnd");
const Withdrawbtn = document.getElementById("withdraw");
const inputfnd = document.getElementById("input");
const withindicator = document.getElementById("w");
const getBalanceIndicator = document.getElementById("i");
inputfnd.placeholder = "Wallet!connected";
inputfnd.disabled = true;
connectbtn.onclick = connect;
fundbtn.onclick = fund;
Balancebtn.onclick = getBalance;
Withdrawbtn.onclick = withdraw;
async function connect() {
  if (typeof window.ethereum !== "undifined") {
    await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    console.log("Connected");
    console.log(ethers);
    inputfnd.disabled = false;
    inputfnd.placeholder = "Amount..";
    icodiv[0].style.color = "green";
    inputfnd.style.border = "2px solid green";
  } else {
    console.log("there's no metamask");
  }
}
//fund function
async function fund(ethAmount) {
  ethAmount = inputfnd.value;
  console.log(`funding with ${ethAmount}...`);
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    console.log(signer);
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      const transactionResponse = await contract.fund({
        value: ethers.utils.parseEther(ethAmount),
      });
      await listenForTransactionMine(transactionResponse, provider);
    } catch (error) {
      console.log(error);
    }
  }
}
function listenForTransactionMine(transactionResponse, provider) {
  console.log(`Mining${transactionResponse.hash}`);

  return new Promise((resolve, reject) => {
    provider.once(transactionResponse.hash, (transactionReceipt) => {
      console.log(
        `competed with ${transactionReceipt.confirmations} comfirmations`
      );
      resolve();
    });
  });
}

async function getBalance() {
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const balance = await provider.getBalance(contractAddress);
    const balancer = ethers.utils.formatEther(balance);
    getBalanceIndicator.innerText = `${balancer}ETH`;
  } else {
    console.log("you have to install metamask");
  }
}
async function withdraw() {
  if (typeof window.ethereum !== "undefined") {
    withindicator.innerText = "Withdrawing...";
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const balancer = await provider.getBalance(contractAddress);
    const balance = ethers.utils.formatEther(balancer);
    const signer = provider.getSigner();
    console.log(signer);
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      const transactionResponse = await contract.withdraw();
      await listenForTransactionMine(transactionResponse, provider);
      withindicator.innerText = `${balance}ETH withdraw Sucessful!`;
    } catch (err) {
      console.log(err);
      withindicator.innerText = `No access to ${balance}ETH ! Owner `;
    }
  }
}
