// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Link-based escrow:
/// Sender deposits ETH against a hash = keccak256(secret).
/// Recipient claims by revealing the secret.
/// Sender can cancel after expiry.
contract EscrowLinks {
    // -------------------------
    // Errors (cheaper than strings)
    // -------------------------
    error LinkAlreadyExists();
    error LinkNotFound();
    error InvalidAmount();
    error InvalidTTL();
    error NotSender();
    error AlreadyClaimed();
    error Expired();
    error NotExpired();
    error ZeroRecipient();
    error TransferFailed();

    // -------------------------
    // Events
    // -------------------------
    event LinkCreated(
        bytes32 indexed hash,
        address indexed sender,
        uint256 amount,
        uint64  expiry,
        bytes32 indexed memoHash
    );

    event Claimed(
        bytes32 indexed hash,
        address indexed recipient,
        uint256 amount
    );

    event Cancelled(
        bytes32 indexed hash,
        address indexed sender,
        uint256 amount
    );

    // -------------------------
    // Storage
    // -------------------------
    struct Link {
        address sender;
        uint128 amount;   // fits up to ~3e38 wei
        uint64  expiry;   // unix timestamp
        bool    claimed;
        bytes32 memoHash; // hashed identifier (email/phone/uuid)
    }

    mapping(bytes32 => Link) public links;

    // -------------------------
    // Reentrancy guard
    // -------------------------
    uint256 private _locked = 1;
    modifier nonReentrant() {
        require(_locked == 1, "REENTRANCY");
        _locked = 2;
        _;
        _locked = 1;
    }

    // -------------------------
    // Core logic
    // -------------------------

    /// @notice Create a link by locking ETH against `hash = keccak256(secret)`.
    /// @param hash The commitment hash of the secret.
    /// @param ttlSeconds How long before sender can cancel (must be > 0).
    /// @param memoHash Hashed off-chain identifier (email/phone/UUID).
    function createLink(
        bytes32 hash,
        uint64 ttlSeconds,
        bytes32 memoHash
    ) external payable {
        if (msg.value == 0) revert InvalidAmount();
        if (ttlSeconds == 0) revert InvalidTTL();

        Link storage l = links[hash];
        if (l.sender != address(0)) revert LinkAlreadyExists();

        uint64 expiry = uint64(block.timestamp) + ttlSeconds;

        links[hash] = Link({
            sender: msg.sender,
            amount: uint128(msg.value),
            expiry: expiry,
            claimed: false,
            memoHash: memoHash
        });

        emit LinkCreated(hash, msg.sender, msg.value, expiry, memoHash);
    }

    /// @notice Claim a link by revealing the secret.
    /// @param secret The preimage used to form the hash.
    /// @param recipient Where funds should be sent (must be non-zero).
    function claim(bytes32 secret, address recipient) external nonReentrant {
        if (recipient == address(0)) revert ZeroRecipient();

        bytes32 hash = keccak256(abi.encodePacked(secret));
        Link storage l = links[hash];

        if (l.sender == address(0)) revert LinkNotFound();
        if (l.claimed) revert AlreadyClaimed();
        if (block.timestamp > l.expiry) revert Expired();

        // effects
        l.claimed = true;
        uint256 amount = uint256(l.amount);

        // interactions
        (bool ok, ) = recipient.call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit Claimed(hash, recipient, amount);
    }

    /// @notice Read full link state (backend/UI helper)
    function getLink(bytes32 hash)
        external
        view
        returns (
            address sender,
            uint128 amount,
            uint64 expiry,
            bool claimed,
            bytes32 memoHash
        )
    {
        Link storage l = links[hash];
        return (l.sender, l.amount, l.expiry, l.claimed, l.memoHash);
    }

    /// @notice Cancel after expiry; returns ETH to the original sender.
    function cancel(bytes32 hash) external nonReentrant {
        Link storage l = links[hash];

        if (l.sender == address(0)) revert LinkNotFound();
        if (msg.sender != l.sender) revert NotSender();
        if (l.claimed) revert AlreadyClaimed();
        if (block.timestamp <= l.expiry) revert NotExpired();

        // effects
        l.claimed = true;
        uint256 amount = uint256(l.amount);

        // interactions
        (bool ok, ) = l.sender.call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit Cancelled(hash, l.sender, amount);
    }

    receive() external payable {
        // direct ETH sends are ignored
    }
}
