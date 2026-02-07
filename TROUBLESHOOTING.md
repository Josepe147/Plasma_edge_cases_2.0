# 🔧 Troubleshooting Guide

Common issues and how to fix them!

## ❌ "Username already taken" Error

### Problem:
You tried to register but the username is already in use from a previous test.

### Solution 1: Use Admin Panel (Easiest)
```
1. Open http://localhost:3000/admin.html
2. Click "Delete All Users" or delete specific user
3. Try registering again
```

### Solution 2: Run Clear Script
```powershell
# PowerShell
.\clear-data.ps1

# Or Command Prompt
clear-data.bat
```

### Solution 3: Manual Deletion
```powershell
# Delete the data folder
Remove-Item data\users\* -Force
```

## ❌ Login Fails After Registration

### Problem:
You registered before, but login doesn't work.

### Possible Causes:

1. **Browser cached old session**
   - Solution: Clear browser cache or use Incognito/Private mode
   - Press `Ctrl+Shift+Delete` → Clear cached data

2. **Wrong password**
   - Solution: Delete the user and re-register with correct password
   - Use admin panel: http://localhost:3000/admin.html

3. **Session storage issue**
   - Solution: Clear browser storage
   ```
   F12 → Application → Storage → Clear site data
   ```

## ❌ Browser Opens to Wrong Page

### Problem:
Startup opens to login.html instead of index.html

### Solution:
Already fixed! Now opens to homepage (index.html) automatically.

```bash
# Just restart:
npm start
```

## ❌ "Email service not configured"

### Problem:
Email sending fails when creating escrow link.

### Solution:
This is OK! Email is optional. The link still works.

**To enable email:**
```bash
# 1. Get API key from resend.com
# 2. Add to .env file:
echo RESEND_API_KEY=re_your_key > .env
# 3. Restart server
npm start
```

## ❌ ENS Error (network does not support ENS)

### Problem:
Error when sending crypto: "network does not support ENS"

### Solution:
Already fixed! The code now uses proper Plasma network config.

```bash
# Just refresh your browser:
Ctrl+R or F5
```

## ❌ Contract Not Deployed

### Problem:
`ESCROW_CONTRACT_ADDRESS: "YOUR_DEPLOYED_CONTRACT_ADDRESS"`

### Solution:
You need to deploy the contract first.

```bash
# Option 1: Deploy during startup
npm start
# Choose "y" when asked to deploy

# Option 2: Deploy manually
.\deploy.bat
```

Then update the address in:
- config.js (line 9)
- send.js (line 13)
- claim.js (line 11)

## ❌ Server Won't Start (Port 3000 in use)

### Problem:
`Error: listen EADDRINUSE: address already in use :::3000`

### Solution:
```powershell
# Find what's using port 3000:
netstat -ano | findstr :3000

# Kill the process (replace PID):
taskkill /F /PID [PID_NUMBER]

# Or change port:
set PORT=3001
npm start
```

## ❌ "Cannot find module 'resend'"

### Problem:
Missing dependencies after git pull or update.

### Solution:
```bash
npm install
```

## 🧹 Complete Reset (Start Fresh)

Want to completely reset everything?

### Keep API Keys:
```powershell
# Delete only user data
.\clear-data.ps1
```

### Reset Everything:
```powershell
# Delete all data (including config)
Remove-Item data -Recurse -Force

# Clear node modules and reinstall
Remove-Item node_modules -Recurse -Force
npm install

# Restart
npm start
```

### Clear Browser Data:
1. Press `F12` (Developer Tools)
2. Go to **Application** tab
3. Click **Clear site data**
4. Or use **Incognito/Private** mode

## 🎯 Quick Fixes Cheat Sheet

| Issue | Quick Fix |
|-------|-----------|
| Username taken | http://localhost:3000/admin.html → Delete |
| Login fails | Clear browser cache + Use Incognito |
| Wrong page opens | Already fixed! Just restart |
| Email not working | Optional - link still works without email |
| ENS error | Refresh browser (Ctrl+R) |
| Port in use | `taskkill /F /PID [PID]` |
| Module missing | `npm install` |

## 📝 Best Practices for Testing

1. **Use Incognito/Private mode** for clean testing
2. **Use admin panel** to manage test accounts
3. **Different usernames** for each test user
4. **Clear data** between major test runs
5. **Check console** (F12) for detailed errors

## 🔍 Where to Find Logs

### Server Logs:
Look at the terminal where you ran `npm start`

### Browser Logs:
1. Press `F12`
2. Go to **Console** tab
3. Look for errors (red text)

### User Data:
```
data/
└── users/
    ├── alice.json
    ├── bob.json
    └── ...
```

## ❓ Still Having Issues?

1. **Check server is running**: http://localhost:3000/health
2. **Clear everything**:
   ```bash
   .\clear-data.ps1
   # Restart browser in Incognito mode
   npm start
   ```
3. **Check your .env file** if using email
4. **Look at console logs** (F12 in browser)

## 🎉 Common Success Steps

1. Run `npm install`
2. Run `npm start`
3. Open http://localhost:3000/
4. Click "Create Account"
5. Register with unique username
6. Start sending crypto!

---

**Still stuck?** Check [README.md](README.md) or [ONE_COMMAND_START.md](ONE_COMMAND_START.md)
