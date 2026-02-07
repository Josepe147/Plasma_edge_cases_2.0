// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EscrowLinks.sol";

contract EscrowLinksTest is Test {
    EscrowLinks escrow;

    address sender = address(0xA11CE);
    address recipient = address(0xB0B);

    bytes32 constant MEMO = keccak256("invite-123");

    function setUp() public {
        escrow = new EscrowLinks();
        vm.deal(sender, 10 ether);
        vm.deal(recipient, 1 ether);
    }

    function _hash(bytes32 secret) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(secret));
    }

    function testCreateAndClaim() public {
        bytes32 secret = keccak256("my-secret");
        bytes32 hash = _hash(secret);

        vm.prank(sender);
        escrow.createLink{value: 1 ether}(hash, 86400, MEMO);

        uint256 beforeBal = recipient.balance;
        escrow.claim(secret, recipient);
        assertEq(recipient.balance, beforeBal + 1 ether);
    }

    function testWrongSecretFails() public {
        bytes32 secret = keccak256("my-secret");
        bytes32 hash = _hash(secret);

        vm.prank(sender);
        escrow.createLink{value: 1 ether}(hash, 86400, MEMO);

        bytes32 wrong = keccak256("wrong");
        vm.expectRevert(EscrowLinks.LinkNotFound.selector);
        escrow.claim(wrong, recipient);
    }

    function testCannotClaimTwice() public {
        bytes32 secret = keccak256("my-secret");
        bytes32 hash = _hash(secret);

        vm.prank(sender);
        escrow.createLink{value: 1 ether}(hash, 86400, MEMO);

        escrow.claim(secret, recipient);

        vm.expectRevert(EscrowLinks.AlreadyClaimed.selector);
        escrow.claim(secret, recipient);
    }

    function testCancelAfterExpiry() public {
        bytes32 secret = keccak256("my-secret");
        bytes32 hash = _hash(secret);

        uint256 senderBefore = sender.balance;

        vm.prank(sender);
        escrow.createLink{value: 1 ether}(hash, 10, MEMO);

        vm.warp(block.timestamp + 11);

        vm.prank(sender);
        escrow.cancel(hash);

        assertEq(sender.balance, senderBefore);
    }

    function testCancelBeforeExpiryFails() public {
        bytes32 secret = keccak256("my-secret");
        bytes32 hash = _hash(secret);

        vm.prank(sender);
        escrow.createLink{value: 1 ether}(hash, 1000, MEMO);

        vm.prank(sender);
        vm.expectRevert(EscrowLinks.NotExpired.selector);
        escrow.cancel(hash);
    }
}
