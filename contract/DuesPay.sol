// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract DuesPay {
    struct Campaign { string title; address treasurer; uint256 amount; uint256 deadline; uint256 collected; uint256 spent; }
    Campaign[] public campaigns;
    mapping(uint256 => mapping(address => bool)) public paid;
    event Paid(uint256 indexed id, address indexed member);

    function create(string calldata title, uint256 amountWei, uint256 deadline) external returns (uint256) {
        campaigns.push(Campaign(title, msg.sender, amountWei, deadline, 0, 0));
        return campaigns.length - 1;
    }
    function payDues(uint256 id) external payable {
        Campaign storage c = campaigns[id];
        require(block.timestamp <= c.deadline && msg.value == c.amount && !paid[id][msg.sender], "invalid");
        paid[id][msg.sender] = true; c.collected += msg.value;
        emit Paid(id, msg.sender);
    }
    function withdraw(uint256 id, address payable to, uint256 amt) external {
        Campaign storage c = campaigns[id];
        require(msg.sender == c.treasurer && c.spent + amt <= c.collected, "invalid");
        c.spent += amt; to.transfer(amt);
    }
}
