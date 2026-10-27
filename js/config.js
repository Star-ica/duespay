// TODO: replace with your deployed contract address
const CHAIN = {
  id: 677, hex: "0x2A5", name: "BOT Chain ",
  symbol: "BOT", rpc: "https://rpc.botchain.ai",
  explorer: "https://scan.botchain.ai", website: "https://botchain.ai"
};

const CONFIG = {
  address: "0xfdc62b3d5fB420a2BDa22013f45ca65D9E613Ef9",
  name: "DuesPay",
  fns: [
    "function create(string title, uint256 amountWei, uint256 deadline) returns (uint256)",
    "function payDues(uint256 id) payable",
    "function withdraw(uint256 id, address to, uint256 amount, string description)",
    "function setPaused(uint256 id, bool paused)",
    "function campaigns(uint256 id) view returns (string,address,uint256,uint256,uint256,uint256,bool)",
    "function paid(uint256 id, address member) view returns (bool)",
    "function campaignCount() view returns (uint256)",
    "function expenseCount() view returns (uint256)",
    "function getMembers(uint256 id) view returns (address[])",
    "function memberCount(uint256 id) view returns (uint256)",
    "function balance(uint256 id) view returns (uint256)",
    "function expenses(uint256 id) view returns (uint256,address,uint256,string,uint256)"
  ]
};
