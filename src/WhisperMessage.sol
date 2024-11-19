// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WhisperMessage {
    struct Message {
        address sender;
        string contentHash;
        uint256 timestamp;
    }

    mapping(address => Message[]) private messages;

    // Send a message to a user (store message hash and sender)
    function sendMessage(address recipient, string memory contentHash) public {
        messages[recipient].push(Message(msg.sender, contentHash, block.timestamp));
    }

    // Get all messages for a user
    function getMessages(address user) public view returns (Message[] memory) {
        return messages[user];
    }
}
