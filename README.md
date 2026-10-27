# DuesPay

On-chain dues collection for classes and associations. Built on BOT Chain.

## Setup

1. Deploy `contract/DuesPay.sol` (Remix, Hardhat, or Foundry) on BOT Chain Testnet (chain ID 677).
2. Set `address` in `js/config.js` to your deployed contract address.
3. Serve this folder with any static file server (e.g. VS Code Live Server, `npx serve .`).
4. Connect your EVM wallet — the app auto-switches to BOT Chain.

## Network

- Chain ID: 677 | RPC: https://rpc.botchain.ai | Explorer: https://scan.botchain.ai

## New in v2 (this release)

- Full contract: `setPaused`, `getMembers`, `memberCount`, `balance`, per-expense `description` and `timestamp`
- Complete frontend: dark fintech UI, read page queries all view functions, write page handles all state-changing functions
- Whitepaper included: `WHITEPAPER.md`

Not audited – use on testnet first.
