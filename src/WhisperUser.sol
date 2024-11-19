// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WhisperUser is EIP712, Ownable {
    string private constant SIGNING_DOMAIN = "WhisperChain";
    string private constant SIGNATURE_VERSION = "1";

    mapping(address => bool) public isRegistered;

    // Mapping to track user-specific nonces
    mapping(address => uint256) private userNonces;

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) Ownable(msg.sender) {}

    // Register a user
    function registerUser(address user) public onlyOwner {
        require(!isRegistered[user], "User already registered.");
        isRegistered[user] = true;
    }

    // Authenticate user with signature
    function authenticateUser(address user, uint256 userNonce, bytes memory signature) public view returns (bool) {
        bytes32 structHash = keccak256(abi.encode(user, userNonce));
        bytes32 digest = _hashTypedDataV4(structHash);  // This should be accessible from EIP712
        return SignatureChecker.isValidSignatureNow(user, digest, signature);
    }

    // Nonce management to prevent replay attacks
    function getNonce(address user) public returns (uint256) {
        return userNonces[user]++;
    }

    // Expose _hashTypedDataV4 for testing purposes (for test contracts)
    function hashTypedDataV4(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }
}
