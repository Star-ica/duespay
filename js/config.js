// TODO: replace with your deployed contract address
const CHAIN={id:968,hex:"0x3c8",name:"BOT Chain Testnet",symbol:"BOT",rpc:"https://rpc.botchain.ai",explorer:"https://scan.botchain.ai",website:"https://botchain.ai"};
const CONFIG={
 "address":"0x0000000000000000000000000000000000000000",
 "name": "DuesPay",
 "fns": [
  "function create(string title,uint256 amountWei,uint256 deadline) returns (uint256)",
  "function payDues(uint256 id) payable",
  "function withdraw(uint256 id,address to,uint256 amountWei)",
  "function campaigns(uint256 id) view returns (string,address,uint256,uint256,uint256,uint256)",
  "function paid(uint256 id,address member) view returns (bool)"
 ]
};