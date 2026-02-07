# 🪟 Windows Quick Start Guide

Three ways to start your Plasma Escrow Links app on Windows:

## 🎯 Option 1: PowerShell (Recommended)

```powershell
# Install dependencies (only once)
npm install

# Start everything
.\start.ps1
```

## 🎯 Option 2: Command Prompt (Simplest)

```batch
# Install dependencies (only once)
npm install

# Start everything
start.bat
```

## 🎯 Option 3: Git Bash (If You Have Git)

```bash
# Install dependencies (only once)
npm install

# Start everything
bash start.sh
```

## ⚡ Super Quick Version

Just double-click `start.bat` in File Explorer!

## 📋 What Each Script Does:

1. ✅ Checks if Node.js is installed
2. ✅ Installs dependencies (if needed)
3. ✅ Creates data directories
4. ✅ Starts backend server on port 3000
5. ✅ Opens browser to http://localhost:3000/

## 🔧 First Time Setup:

### Step 1: Install Node.js
If you don't have Node.js:
1. Download from https://nodejs.org
2. Install (use defaults)
3. Restart terminal/PowerShell

### Step 2: Install Dependencies
```powershell
npm install
```

### Step 3: Run Startup Script
**PowerShell:**
```powershell
.\start.ps1
```

**Command Prompt:**
```batch
start.bat
```

**Git Bash:**
```bash
bash start.sh
```

## 🌐 After Starting:

Browser opens automatically to:
```
http://localhost:3000/
```

Then:
1. Click **"Create Account"**
2. Register with username/password
3. Wallet is auto-generated and encrypted
4. Start sending XPL via links!

## 🛑 Stopping the Server:

### If using start.ps1:
- Press any key in the PowerShell window

### If using start.bat:
- Press any key in the Command Prompt window

### If server is running in background:
```powershell
# Find node processes
Get-Process node

# Kill specific process
Stop-Process -Id PROCESS_ID

# Or kill all node processes
taskkill /F /IM node.exe
```

## 🐛 Troubleshooting:

### "cannot be loaded because running scripts is disabled"
**Solution:** Run PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Port 3000 is already in use"
**Solution:** Kill existing process:
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual process ID)
taskkill /F /PID [PID]
```

### "npm is not recognized"
**Solution:** Install Node.js from https://nodejs.org

### Browser doesn't open automatically
**Solution:** Manually open: http://localhost:3000/

## 📁 Where Your Data is Stored:

```
data/
├── users/
│   ├── username1.json  (encrypted wallet)
│   ├── username2.json  (encrypted wallet)
│   └── ...
└── config.json         (contract address)
```

## 🔒 Security:

- ✅ Private keys encrypted with AES-256-GCM
- ✅ Passwords hashed with PBKDF2
- ✅ Session-based authentication
- ✅ Data stored locally on your machine

## 🚀 Complete Flow:

```
1. Run start.bat (or start.ps1)
   ↓
2. Browser opens to http://localhost:3000/
   ↓
3. Click "Create Account"
   ↓
4. Register with username/password
   ↓
5. Wallet auto-generated & encrypted
   ↓
6. Dashboard shows your balance
   ↓
7. Click "Send Crypto Link"
   ↓
8. Send XPL to anyone via link!
```

## 💡 Tips:

- **First time?** Use `start.bat` - it's the simplest
- **Want more control?** Use `start.ps1` in PowerShell
- **Have Git Bash?** Use `bash start.sh`
- **Bookmark** http://localhost:3000/ for easy access

## 📖 Next Steps:

1. Read [ONE_COMMAND_START.md](ONE_COMMAND_START.md) for detailed guide
2. Deploy contract (when starting, or later)
3. Register an account
4. Send your first escrow link!

---

**Need help?** Check the troubleshooting section above or open an issue.
