# 🚀 One Command Startup Guide

Run everything with a single command! Your private keys are now securely stored and you can log back in anytime.

## ✨ What's New?

- 🔐 **Secure Authentication**: Login with username/password
- 💾 **Encrypted Storage**: Private keys stored encrypted in `data/users/`
- 🚀 **Single Command**: Everything starts automatically
- 🌐 **Auto-Open Browser**: Opens directly to the app

## 📋 Prerequisites

Install dependencies first (only needed once):

```bash
npm install
```

## 🎯 Single Command Startup

### For Bash (Linux/Mac/Git Bash):

```bash
chmod +x start.sh
./start.sh
```

That's it! The script will:
1. ✅ Check dependencies
2. ✅ Deploy contract (if needed) or use existing
3. ✅ Start backend server on port 3000
4. ✅ Auto-open browser to http://localhost:3000/

## 🔐 How Authentication Works

### First Time (Register):

1. Browser opens to home page
2. Click "Create Account"
3. Fill in:
   - Forename
   - Surname
   - Username
   - Password
4. **A new wallet is automatically generated and encrypted**
5. Your encrypted private key is stored in `data/users/YOUR_USERNAME.json`
6. You're logged in and redirected to dashboard

### Coming Back (Login):

1. Run `./start.sh` again
2. Click "Login"
3. Enter username and password
4. Your private key is decrypted and you're logged in
5. See your wallet balance and send XPL

## 📁 Where Data is Stored

```
data/
├── users/
│   ├── alice.json       # Alice's encrypted wallet
│   ├── bob.json         # Bob's encrypted wallet
│   └── charlie.json     # Charlie's encrypted wallet
└── config.json          # Deployed contract address
```

### User File Format:
```json
{
  "username": "alice",
  "passwordHash": "...",  // Hashed password
  "salt": "...",
  "forename": "Alice",
  "surname": "Smith",
  "email": "alice@example.com",
  "walletAddress": "0x...",
  "encryptedPrivateKey": {  // Encrypted with AES-256-GCM
    "iv": "...",
    "encryptedData": "...",
    "authTag": "..."
  },
  "createdAt": "2026-02-07T..."
}
```

## 🔒 Security Features

1. **Password Hashing**: PBKDF2 with 100,000 iterations
2. **Encryption**: AES-256-GCM for private keys
3. **Session Management**: Credentials only in memory during session
4. **Logout**: Clears all session data

## 🎮 Complete User Flow

```
┌─────────────────────────────────────────┐
│  1. Run: ./start.sh                     │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  2. Browser opens automatically         │
│     http://localhost:3000/              │
└───────────────┬─────────────────────────┘
                │
       ┌────────┴────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌─────────────┐
│  New User?  │   │ Have Account│
│  Register   │   │    Login    │
└──────┬──────┘   └──────┬──────┘
       │                 │
       │  Auto-generates │  Decrypts
       │  wallet         │  existing wallet
       │                 │
       └────────┬────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  3. Dashboard shows:                    │
│     • Your wallet address               │
│     • Current XPL balance               │
│     • Send button                       │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  4. Click "Send Crypto Link"            │
│     • Enter recipient email             │
│     • Enter amount (XPL)                │
│     • Add optional message              │
│     • Set expiry time                   │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  5. Claim link generated                │
│     • Copy and send to recipient        │
│     • Or email automatically            │
└─────────────────────────────────────────┘
```

## 🛠️ Available Commands

```bash
# Start everything (recommended)
./start.sh

# Or manually start backend
npm start

# Or with Node.js directly
node server.js
```

## 📡 API Endpoints

The backend server provides these endpoints:

- `POST /api/register` - Create new account
- `POST /api/login` - Login
- `GET /api/user/:username` - Get user profile
- `GET /api/config` - Get contract configuration
- `POST /api/deploy` - Deploy contract (admin)
- `GET /health` - Health check

## 🔧 Environment Variables

Optional (defaults work fine):

```bash
# Port for backend server (default: 3000)
export PORT=3000

# Custom encryption key (auto-generated if not set)
export ENCRYPTION_KEY="your-32-byte-hex-key"

# RPC URL (default: Plasma testnet)
export RPC_URL="https://testnet-rpc.plasma.to"
```

## 🎯 Quick Testing

1. **Start the app:**
   ```bash
   ./start.sh
   ```

2. **Register first user:**
   - Username: `test1`
   - Password: `password123`
   - Name: `Test User`

3. **Send escrow link:**
   - Go to "Send Crypto Link"
   - Recipient: `test2@example.com`
   - Amount: `0.01` XPL

4. **Open claim link:**
   - Copy the generated link
   - Open in incognito/private window
   - Register as `test2` and claim

5. **Log back in as test1:**
   - Logout
   - Login with `test1` credentials
   - Your wallet is restored!

## 🚀 Deployment Scenarios

### Scenario 1: Contract Already Deployed

```bash
# Just start - it will detect existing deployment
./start.sh
```

### Scenario 2: First Time Setup

```bash
# Set your deployment key
export RPC_URL="https://testnet-rpc.plasma.to"
export PRIVATE_KEY="0xYOUR_PRIVATE_KEY"

# Start - will offer to deploy
./start.sh
# Choose "y" when asked to deploy
```

### Scenario 3: Deploy Later

```bash
# Start without contract
./start.sh
# Choose "n" when asked to deploy

# Then visit http://localhost:3000/admin.html
# (Admin panel would need to be created)
```

## 📝 Backup Your Data

**Important**: Backup the `data/` directory to preserve user accounts!

```bash
# Backup
tar -czf plasma-backup-$(date +%Y%m%d).tar.gz data/

# Restore
tar -xzf plasma-backup-20260207.tar.gz
```

## 🔄 Stopping the Server

Press `Ctrl+C` in the terminal where start.sh is running.

## 🐛 Troubleshooting

### Issue: "npm install fails"

```bash
# Try:
npm cache clean --force
rm -rf node_modules
npm install
```

### Issue: "Port 3000 already in use"

```bash
# Change port:
PORT=3001 ./start.sh

# Or kill existing process:
lsof -ti:3000 | xargs kill
```

### Issue: "Can't decrypt wallet"

The encryption key changed. Either:
1. Use the same ENCRYPTION_KEY environment variable
2. Or re-register (old wallets won't be accessible)

### Issue: "Browser doesn't open"

Manually open: `http://localhost:3000/`

## 🎉 You're Done!

Now you have a complete crypto escrow system with:
- ✅ Persistent user accounts
- ✅ Encrypted wallet storage
- ✅ One command to start everything
- ✅ Auto-opening browser
- ✅ Login/logout functionality

**Next**: Try sending your first escrow link!

---

**Built for Plasma Hackathon 2.0** 🚀
