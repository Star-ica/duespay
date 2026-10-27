# DuesPay Whitepaper
**Version 1.0 · October 2026**

---

## Abstract

DuesPay is a smart-contract protocol for transparent, trustless dues collection deployed on BOT Chain. It replaces manual payment tracking and treasurer-controlled bank accounts with a fully on-chain campaign system in which every payment, balance change, and expense is permanently and publicly auditable. The protocol requires zero infrastructure beyond a deployed Solidity contract and a static frontend.

---

## 1. Problem Statement

Student associations, professional bodies, cooperatives, and class groups routinely collect membership dues. Today this is done through:

- **Manual collection** — cash or bank transfer tracked in spreadsheets. No auditability, fraud risk.
- **Centralised platforms** — require accounts, charge fees, and can freeze funds.
- **Treasurer trust** — members must trust a single person to handle all funds correctly.

These approaches suffer from opacity, error, and single-point-of-failure risk. There is no permissionless way to verify that dues were collected in full and spent appropriately.

---

## 2. Solution

DuesPay encodes the entire dues lifecycle in a single Solidity contract:

1. **Create** — Treasurer deploys a named campaign with a fixed per-member amount and a deadline.
2. **Collect** — Members send the exact required amount before the deadline; the contract rejects any other value or late payments.
3. **Spend** — Treasurer withdraws to pay for approved expenses. Every withdrawal requires a description stored on-chain and cannot exceed the total collected.
4. **Audit** — Anyone can query paid status, member lists, expenses, and balances at any time.

---

## 3. Contract Architecture

### 3.1 Data Model

```solidity
struct Campaign {
    string  title;
    address treasurer;
    uint256 amountWei;
    uint256 deadline;
    uint256 collected;
    uint256 spent;
    bool    paused;
}

struct Expense {
    uint256 campaignId;
    address payable recipient;
    uint256 amount;
    string  description;
    uint256 timestamp;
}
```

### 3.2 Key Invariants

| Invariant | Enforcement |
|-----------|-------------|
| Exact payment | `require(msg.value == c.amountWei)` |
| One payment per member | `require(!paid[id][msg.sender])` |
| No overspending | `require(c.spent + amount <= c.collected)` |
| Treasurer-only spend | `require(msg.sender == c.treasurer)` |
| Deadline enforced | `require(block.timestamp <= c.deadline)` |

### 3.3 Functions

**Write (state-changing)**

| Function | Role | Description |
|----------|------|-------------|
| `create(title, amountWei, deadline)` | Any | Opens a new dues campaign |
| `payDues(id)` | Member | Pays dues; exact ETH value required |
| `withdraw(id, to, amount, description)` | Treasurer | Withdraws for a named expense |
| `setPaused(id, paused)` | Treasurer | Pauses/unpauses new payments |

**Read (view)**

| Function | Returns |
|----------|---------|
| `campaigns(id)` | Full campaign struct |
| `paid(id, address)` | True if address has paid |
| `campaignCount()` | Total number of campaigns |
| `getMembers(id)` | Array of addresses that paid |
| `memberCount(id)` | Count of paying members |
| `balance(id)` | Available (uncollected–unspent) |
| `expenseCount()` | Total expenses across all campaigns |
| `expenses(id)` | Expense struct by index |

---

## 4. Security Properties

### 4.1 Reentrancy
`withdraw()` uses the checks-effects-interactions pattern: `c.spent` is incremented and the `Expense` record is pushed **before** `to.transfer(amt)`, preventing reentrancy exploits.

### 4.2 Integer overflow
The contract targets Solidity ≥ 0.8.20 where arithmetic is checked by default — overflow/underflow reverts automatically.

### 4.3 Access control
The treasurer address is immutable after campaign creation. There is no admin role and no upgrade mechanism, minimising attack surface.

### 4.4 Pause mechanism
The `paused` flag allows the treasurer to stop incoming payments temporarily without losing any state — useful while a membership dispute or deadline extension is resolved.

---

## 5. Event Log

All state changes emit events, enabling off-chain indexers and explorers to reconstruct the full history without re-reading storage:

```
CampaignCreated(id, title, treasurer, amountWei, deadline)
DuesPaid(id, member, amount)
Withdrawn(id, expenseId, to, amount, description)
CampaignPaused(id, paused)
```

---

## 6. Deployment & Integration

### 6.1 Network
BOT Chain Testnet — Chain ID 677, RPC `https://rpc.botchain.ai`, Explorer `https://scan.botchain.ai`.

### 6.2 Deployment steps
1. Compile `contract/DuesPay.sol` with Solidity 0.8.20+.
2. Deploy via Remix, Hardhat, or Foundry.
3. Copy the deployed address into `js/config.js`.
4. Serve the frontend with any static file server.

### 6.3 Frontend
The included frontend (index, read, write pages) uses ethers.js v6 and auto-switches the user's wallet to BOT Chain. The read page renders all `view` functions; the write page renders all state-changing functions, each with a labelled input per parameter and a transaction-status output.

---

## 7. Limitations & Disclaimer

- **Not audited.** Use on testnet before any mainnet deployment.
- **No partial payments.** All-or-nothing: members must send exactly the required amount.
- **No refund mechanism.** Late payments are rejected; the contract does not return funds from a campaign to members if it under-collects. Consider this when setting the amount and deadline.
- **Treasurer key security.** Whoever holds the treasurer private key controls all withdrawals. Multi-sig treasurers should deploy with a Safe (Gnosis Safe) address as treasurer.

---

## 8. Roadmap

| Milestone | Description |
|-----------|-------------|
| v1.1 | Multi-treasurer approval (2-of-3 multisig pattern) |
| v1.2 | ERC-20 token support (USDC, stablecoins) |
| v1.3 | Partial-payment plans (instalments) |
| v2.0 | Factory contract for one-click campaign creation |

---

*DuesPay · Built on BOT Chain · © 2026*
