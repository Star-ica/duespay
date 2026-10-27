// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DuesPay – Transparent dues collection for classes and associations
/// @notice Treasurer creates a campaign; members pay exact dues before deadline;
///         treasurer withdraws up to the total collected, tracked per expense.
contract DuesPay {
    // ─── Structs ───────────────────────────────────────────────────────────

    struct Campaign {
        string  title;
        address treasurer;
        uint256 amountWei;   // exact amount each member must pay
        uint256 deadline;    // unix timestamp
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

    // ─── State ─────────────────────────────────────────────────────────────

    Campaign[] public campaigns;
    Expense[]  public expenses;

    /// paid[campaignId][member] = true once they've paid
    mapping(uint256 => mapping(address => bool)) public paid;

    /// memberList[campaignId] = list of members who paid (for enumeration)
    mapping(uint256 => address[]) private memberList;

    // ─── Events ────────────────────────────────────────────────────────────

    event CampaignCreated(uint256 indexed id, string title, address indexed treasurer, uint256 amountWei, uint256 deadline);
    event DuesPaid(uint256 indexed id, address indexed member, uint256 amount);
    event Withdrawn(uint256 indexed id, uint256 expenseId, address indexed to, uint256 amount, string description);
    event CampaignPaused(uint256 indexed id, bool paused);

    // ─── Modifiers ─────────────────────────────────────────────────────────

    modifier onlyTreasurer(uint256 id) {
        require(msg.sender == campaigns[id].treasurer, "not treasurer");
        _;
    }

    modifier validCampaign(uint256 id) {
        require(id < campaigns.length, "bad id");
        _;
    }

    // ─── Write functions ───────────────────────────────────────────────────

    /// @notice Create a new dues campaign
    /// @param title       Human-readable name (e.g. "Year 2 Engineering Dues")
    /// @param amountWei   Exact wei each member must send
    /// @param deadline    Unix timestamp after which no payments are accepted
    /// @return id         Index of the newly created campaign
    function create(
        string calldata title,
        uint256 amountWei,
        uint256 deadline
    ) external returns (uint256 id) {
        require(bytes(title).length > 0,  "empty title");
        require(amountWei > 0,            "amount must be > 0");
        require(deadline > block.timestamp, "deadline in past");

        id = campaigns.length;
        campaigns.push(Campaign({
            title:      title,
            treasurer:  msg.sender,
            amountWei:  amountWei,
            deadline:   deadline,
            collected:  0,
            spent:      0,
            paused:     false
        }));

        emit CampaignCreated(id, title, msg.sender, amountWei, deadline);
    }

    /// @notice Pay dues for a campaign — send exactly the required amount
    function payDues(uint256 id) external payable validCampaign(id) {
        Campaign storage c = campaigns[id];
        require(!c.paused,                       "campaign paused");
        require(block.timestamp <= c.deadline,   "deadline passed");
        require(msg.value == c.amountWei,        "wrong amount");
        require(!paid[id][msg.sender],           "already paid");

        paid[id][msg.sender] = true;
        c.collected += msg.value;
        memberList[id].push(msg.sender);

        emit DuesPaid(id, msg.sender, msg.value);
    }

    /// @notice Withdraw funds from a campaign to cover an expense
    /// @param id          Campaign index
    /// @param to          Recipient address
    /// @param amount      Amount in wei to send
    /// @param description Short description of the expense (stored on-chain)
    function withdraw(
        uint256 id,
        address payable to,
        uint256 amount,
        string calldata description
    ) external validCampaign(id) onlyTreasurer(id) {
        Campaign storage c = campaigns[id];
        require(to != address(0),                "zero address");
        require(amount > 0,                      "zero amount");
        require(c.spent + amount <= c.collected, "insufficient funds");
        require(bytes(description).length > 0,   "empty description");

        c.spent += amount;
        uint256 expId = expenses.length;
        expenses.push(Expense({
            campaignId:  id,
            recipient:   to,
            amount:      amount,
            description: description,
            timestamp:   block.timestamp
        }));

        to.transfer(amount);
        emit Withdrawn(id, expId, to, amount, description);
    }

    /// @notice Pause or unpause a campaign (prevents new payments)
    function setPaused(uint256 id, bool paused) external validCampaign(id) onlyTreasurer(id) {
        campaigns[id].paused = paused;
        emit CampaignPaused(id, paused);
    }

    // ─── View functions ────────────────────────────────────────────────────

    /// @notice Returns the number of campaigns created
    function campaignCount() external view returns (uint256) {
        return campaigns.length;
    }

    /// @notice Returns the number of expenses recorded
    function expenseCount() external view returns (uint256) {
        return expenses.length;
    }

    /// @notice Returns all members who paid for a campaign
    function getMembers(uint256 id) external view validCampaign(id) returns (address[] memory) {
        return memberList[id];
    }

    /// @notice Returns the number of members who paid for a campaign
    function memberCount(uint256 id) external view validCampaign(id) returns (uint256) {
        return memberList[id].length;
    }

    /// @notice Returns available balance (collected minus spent) for a campaign
    function balance(uint256 id) external view validCampaign(id) returns (uint256) {
        Campaign storage c = campaigns[id];
        return c.collected - c.spent;
    }
}
