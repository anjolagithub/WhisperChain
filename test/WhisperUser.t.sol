// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/WhisperUser.sol";

contract WhisperUserTest is Test {
    WhisperUser private whisperUser;

    function setUp() public {
        whisperUser = new WhisperUser();
    }

    function testRegisterUser() public {
        address user = address(0x123);
        whisperUser.registerUser(user);
        assertTrue(whisperUser.isRegistered(user), "User should be registered");
    }

    function testAuthenticateUser() public {
        address user = address(0x123);
        whisperUser.registerUser(user);

        // Get the correct nonce for the user
        uint256 userNonce = whisperUser.getNonce(user);

        // Sign the message using the owner's private key
        bytes memory signature = signMessage(user, userNonce);

        // Authenticate the user
        bool isAuthenticated = whisperUser.authenticateUser(user, userNonce, signature);
        assertTrue(isAuthenticated, "User should be authenticated");
    }

    function signMessage(address user, uint256 nonce) public view returns (bytes memory) {
        // Create the struct hash
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Authentication(address user,uint256 nonce)"),
            user,
            nonce
        ));

        // Generate the digest using the contract's method
        bytes32 digest = whisperUser.hashTypedDataV4(structHash);

        // Use the first account (deployer) to sign the message
        address signer = vm.addr(0);  // Using the first account in the testing environment
        
        // Ensure the signer is valid (this should never be zero)
        require(signer != address(0), "Invalid signer address");

        // Sign the digest and get the signature components (v, r, s)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        
        // Return the concatenation of r, s, and v as a single byte array
        return abi.encodePacked(r, s, v);
    }
}
