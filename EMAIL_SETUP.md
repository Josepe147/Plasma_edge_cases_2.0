# 📧 Email Setup Guide

Enable automatic email sending when creating escrow links!

## 🎯 What This Does

When you create an escrow link, the system will automatically send an email to the recipient with:
- A beautiful HTML email template
- The claim link
- Amount being sent
- Your custom message
- Instructions for claiming

## ⚡ Quick Setup (2 Minutes)

### Step 1: Get Resend API Key

1. Go to [resend.com](https://resend.com)
2. Sign up for free account
3. Go to API Keys
4. Create new API key
5. Copy the key (starts with `re_`)

### Step 2: Create .env File

Create a file called `.env` in your project root:

```bash
# Copy the example file
cp .env.example .env

# Or on Windows:
copy .env.example .env
```

### Step 3: Add Your API Key

Edit `.env` file and add your Resend API key:

```env
# Email Service
RESEND_API_KEY=re_YOUR_ACTUAL_API_KEY_HERE

# Other optional settings
PORT=3000
```

### Step 4: Restart Server

```bash
# Stop current server (Ctrl+C)
# Then restart:
npm start
```

You should see:
```
📧 Email service: Enabled ✅
```

## ✅ Test It!

1. **Start server**: `npm start`
2. **Login**: http://localhost:3000/login.html
3. **Send XPL**: http://localhost:3000/send.html
4. **Enter email**: Use your own email to test
5. **Create link**: Click "Create Escrow Link"
6. **Check inbox**: You should receive the email!

## 📧 Email Features

The automated email includes:

- 🎨 **Beautiful Design**: Professional gradient header
- 💰 **Amount Display**: Large, clear XPL amount
- 💬 **Personal Message**: Your custom message (if provided)
- 🔗 **Claim Button**: Big, clickable button
- 📋 **Backup Link**: Plain text link as fallback
- ℹ️ **Instructions**: Explains how to claim (even without wallet)
- 🔒 **Security Info**: Reassures recipient about security

## 🆓 Free Tier Limits

Resend free tier includes:
- ✅ 100 emails per day
- ✅ 3,000 emails per month
- ✅ All features unlocked
- ✅ No credit card required

Perfect for testing and small-scale usage!

## 🎨 Email Preview

```
╔════════════════════════════════════╗
║   🎁 You've Received Crypto!       ║
╚════════════════════════════════════╝

Hi!

Great news! Someone has sent you crypto
on the Plasma network.

💰 0.1 XPL

"Here's some crypto for coffee! ☕"

┌─────────────────────────────┐
│     [Claim My Crypto]       │  ← Button
└─────────────────────────────┘

Don't have a wallet? No problem!
You can create one when you claim.

© 2026 Plasma
```

## 🔧 Troubleshooting

### Email Not Sending

**Check server logs:**
```
📧 Email service: Disabled ⚠️
```

**Solutions:**
1. Verify `.env` file exists in project root
2. Check API key starts with `re_`
3. Restart server after adding key
4. Check console for error messages

### "Email service not configured" Error

The backend is working, but no API key set.

**Solution:**
1. Add `RESEND_API_KEY` to `.env`
2. Restart server

### Email Goes to Spam

**For testing:**
- Use your own email first
- Check spam folder
- Mark as "Not Spam"

**For production:**
- Verify your domain with Resend
- Use a custom domain email (not onboarding@resend.dev)

### Rate Limit Reached

Free tier: 100 emails/day

**Solutions:**
- Wait for reset (daily)
- Upgrade Resend plan
- Or just copy/paste links manually

## 🚀 Without Email Service

Email is **optional**! The system works fine without it:

1. ❌ No email sent
2. ✅ Link still created
3. ✅ Shows warning: "Email service unavailable"
4. ✅ Copy link manually and share

## 🔐 Security Notes

- API key stored in `.env` file (not committed to git)
- Emails sent from backend (secure)
- No recipient data stored permanently
- Only email address and claim link sent

## 📝 .env File Example

```env
# Server Configuration
PORT=3000

# Email Service (Required for automatic emails)
RESEND_API_KEY=re_your_actual_key_here

# Encryption (Optional - auto-generated)
# ENCRYPTION_KEY=64_character_hex_string

# Blockchain (For deployment)
RPC_URL=https://testnet-rpc.plasma.to
# PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

## 🎉 You're Done!

Now when you create escrow links, recipients get:
- ✅ Instant email notification
- ✅ Beautiful professional design
- ✅ Easy one-click claiming
- ✅ Clear instructions

No more manual copying and pasting! 🚀

---

**Questions?** Check the main [README.md](README.md) or [ONE_COMMAND_START.md](ONE_COMMAND_START.md)
