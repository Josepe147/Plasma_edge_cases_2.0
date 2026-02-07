// Plasma Escrow Links - Backend Server
// Handles authentication, wallet storage, and contract deployment

import express from "express";
import cors from "cors";
import crypto from "crypto";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { Wallet } from "ethers";
import { execSync } from "child_process";
import { Resend } from "resend";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

const PORT = process.env.PORT || 3000;
const USERS_DIR = path.join(__dirname, "data", "users");
const CONFIG_FILE = path.join(__dirname, "data", "config.json");

// Encryption settings
const ALGORITHM = "aes-256-gcm";
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || crypto.randomBytes(32).toString("hex");

// Email service (optional - only works if RESEND_API_KEY is set)
const resend = process.env.RESEND_API_KEY ? new Resend(process.env.RESEND_API_KEY) : null;

// IN-MEMORY STORAGE (no persistence - fresh each time)
const IN_MEMORY_USERS = new Map();
console.log("⚠️  Using in-memory storage - users will NOT persist between restarts");

// Load or initialize config
let config = {
  contractAddress: "YOUR_DEPLOYED_CONTRACT_ADDRESS",
  rpcUrl: "https://testnet-rpc.plasma.to",
  deployed: false
};

if (fs.existsSync(CONFIG_FILE)) {
  config = JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
}

function saveConfig() {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
}

// Encryption functions
function encrypt(text) {
  const iv = crypto.randomBytes(16);
  const key = Buffer.from(ENCRYPTION_KEY.slice(0, 64), "hex");
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

  let encrypted = cipher.update(text, "utf8", "hex");
  encrypted += cipher.final("hex");

  const authTag = cipher.getAuthTag();

  return {
    iv: iv.toString("hex"),
    encryptedData: encrypted,
    authTag: authTag.toString("hex")
  };
}

function decrypt(encrypted) {
  const key = Buffer.from(ENCRYPTION_KEY.slice(0, 64), "hex");
  const decipher = crypto.createDecipheriv(
    ALGORITHM,
    key,
    Buffer.from(encrypted.iv, "hex")
  );

  decipher.setAuthTag(Buffer.from(encrypted.authTag, "hex"));

  let decrypted = decipher.update(encrypted.encryptedData, "hex", "utf8");
  decrypted += decipher.final("utf8");

  return decrypted;
}

// Hash password
function hashPassword(password, salt) {
  return crypto.pbkdf2Sync(password, salt, 100000, 64, "sha512").toString("hex");
}

// User storage functions (IN-MEMORY - no persistence)
function userExists(username) {
  return IN_MEMORY_USERS.has(username);
}

function saveUser(userData) {
  IN_MEMORY_USERS.set(userData.username, userData);
  console.log(`✅ User registered: ${userData.username} (in-memory)`);
}

function loadUser(username) {
  return IN_MEMORY_USERS.get(username) || null;
}

function getAllUsers() {
  return Array.from(IN_MEMORY_USERS.values());
}

function deleteUser(username) {
  return IN_MEMORY_USERS.delete(username);
}

function clearAllUsers() {
  const count = IN_MEMORY_USERS.size;
  IN_MEMORY_USERS.clear();
  return count;
}

// API: Register new user
app.post("/api/register", (req, res) => {
  try {
    const { username, password, forename, surname, email } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }

    if (userExists(username)) {
      return res.status(400).json({
        error: "Username already taken",
        message: "This username is already registered. Try logging in or use a different username.",
        hint: "Run 'clear-data.bat' to reset all accounts for testing"
      });
    }

    // Generate new wallet
    const wallet = Wallet.createRandom();

    // Hash password
    const salt = crypto.randomBytes(16).toString("hex");
    const passwordHash = hashPassword(password, salt);

    // Encrypt private key
    const encryptedPrivateKey = encrypt(wallet.privateKey);

    // Save user data
    const userData = {
      username,
      passwordHash,
      salt,
      forename,
      surname,
      email,
      walletAddress: wallet.address,
      encryptedPrivateKey,
      mnemonic: wallet.mnemonic.phrase,
      createdAt: new Date().toISOString()
    };

    saveUser(userData);

    res.json({
      success: true,
      username,
      walletAddress: wallet.address
    });

  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// API: Login
app.post("/api/login", (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }

    const user = loadUser(username);
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // Verify password
    const passwordHash = hashPassword(password, user.salt);
    if (passwordHash !== user.passwordHash) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // Decrypt private key
    const privateKey = decrypt(user.encryptedPrivateKey);

    res.json({
      success: true,
      user: {
        username: user.username,
        forename: user.forename,
        surname: user.surname,
        email: user.email,
        walletAddress: user.walletAddress
      },
      privateKey // Only sent over HTTPS in production!
    });

  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// API: Get user profile (requires username)
app.get("/api/user/:username", (req, res) => {
  try {
    const user = loadUser(req.params.username);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      username: user.username,
      forename: user.forename,
      surname: user.surname,
      email: user.email,
      walletAddress: user.walletAddress
    });

  } catch (error) {
    res.status(500).json({ error: "Failed to load user" });
  }
});

// API: Get contract config
app.get("/api/config", (req, res) => {
  res.json(config);
});

// API: Deploy contract (if not already deployed)
app.post("/api/deploy", async (req, res) => {
  try {
    if (config.deployed) {
      return res.json({
        success: true,
        message: "Contract already deployed",
        contractAddress: config.contractAddress
      });
    }

    const { privateKey } = req.body;

    if (!privateKey) {
      return res.status(400).json({ error: "Private key required for deployment" });
    }

    // Set environment variables and deploy
    process.env.RPC_URL = config.rpcUrl;
    process.env.PRIVATE_KEY = privateKey;

    console.log("Deploying contract...");
    const output = execSync(
      'forge script script/DeployEscrowLinks.s.sol:DeployEscrowLinks --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast',
      { encoding: "utf8", cwd: __dirname }
    );

    // Extract contract address from broadcast file
    const broadcastFiles = execSync(
      'ls -t broadcast/DeployEscrowLinks.s.sol/*/run-latest.json',
      { encoding: "utf8", cwd: __dirname }
    ).trim().split("\n");

    if (broadcastFiles.length > 0) {
      const broadcastData = JSON.parse(fs.readFileSync(broadcastFiles[0], "utf8"));

      for (const tx of broadcastData.transactions || []) {
        if (tx.contractAddress) {
          config.contractAddress = tx.contractAddress;
          config.deployed = true;
          saveConfig();

          // Update frontend config files
          updateFrontendConfig(tx.contractAddress);

          return res.json({
            success: true,
            contractAddress: tx.contractAddress,
            message: "Contract deployed successfully"
          });
        }
      }
    }

    res.status(500).json({ error: "Failed to extract contract address" });

  } catch (error) {
    console.error("Deployment error:", error);
    res.status(500).json({ error: error.message });
  }
});

// Update frontend config files with deployed address
function updateFrontendConfig(contractAddress) {
  const files = ["config.js", "send.js", "claim.js"];

  files.forEach(file => {
    const filePath = path.join(__dirname, file);
    if (fs.existsSync(filePath)) {
      let content = fs.readFileSync(filePath, "utf8");
      content = content.replace(/YOUR_DEPLOYED_CONTRACT_ADDRESS/g, contractAddress);
      fs.writeFileSync(filePath, content);
      console.log(`✅ Updated ${file}`);
    }
  });
}

// API: Send claim email
app.post("/api/send-email", async (req, res) => {
  try {
    if (!resend) {
      return res.status(503).json({
        error: "Email service not configured",
        message: "Set RESEND_API_KEY in .env file to enable email sending"
      });
    }

    const { email, claimUrl, amount, message } = req.body;

    if (!email || !claimUrl || !amount) {
      return res.status(400).json({
        error: "Missing required fields: email, claimUrl, amount"
      });
    }

    // Email HTML template
    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .amount { font-size: 32px; font-weight: bold; color: #667eea; margin: 20px 0; }
          .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
          .message { background: white; padding: 15px; border-left: 4px solid #667eea; margin: 20px 0; font-style: italic; }
          .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎁 You've Received Crypto!</h1>
          </div>
          <div class="content">
            <p>Hi!</p>
            <p>Great news! Someone has sent you crypto on the Plasma network.</p>
            <div class="amount">💰 ${amount} XPL</div>
            ${message ? `<div class="message">"${message}"</div>` : ''}
            <p>Click the button below to claim your funds:</p>
            <a href="${claimUrl}" class="button">Claim My Crypto</a>
            <p style="color: #666; font-size: 14px;">
              Or copy and paste this link into your browser:<br>
              <code>${claimUrl}</code>
            </p>
            <p style="margin-top: 30px; font-size: 14px; color: #666;">
              <strong>Don't have a wallet?</strong> No problem! You can create one when you claim.
            </p>
            <div class="footer">
              <p>This is a secure escrow link powered by Plasma blockchain.</p>
              <p>© 2026 Plasma - Your funds are safe and waiting for you!</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `;

    const result = await resend.emails.send({
      from: "Plasma Wallet <onboarding@resend.dev>",
      to: email,
      subject: `🎁 You've received ${amount} XPL!`,
      html: emailHtml
    });

    console.log("✅ Email sent successfully:", result);

    res.json({
      success: true,
      messageId: result.id
    });

  } catch (error) {
    console.error("❌ Email sending failed:", error);
    res.status(500).json({
      error: "Failed to send email",
      details: error.message
    });
  }
});

// API: List all users (for admin/testing)
app.get("/api/users", (req, res) => {
  try {
    const users = getAllUsers().map(userData => ({
      username: userData.username,
      forename: userData.forename,
      surname: userData.surname,
      email: userData.email,
      walletAddress: userData.walletAddress,
      createdAt: userData.createdAt
    }));

    res.json({ users, count: users.length });
  } catch (error) {
    res.status(500).json({ error: "Failed to list users" });
  }
});

// API: Delete user (for testing)
app.delete("/api/user/:username", (req, res) => {
  try {
    const { username } = req.params;

    if (!userExists(username)) {
      return res.status(404).json({ error: "User not found" });
    }

    deleteUser(username);

    res.json({
      success: true,
      message: `User ${username} deleted from memory`
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to delete user" });
  }
});

// API: Clear all users (for testing)
app.post("/api/clear-all-users", (req, res) => {
  try {
    const count = clearAllUsers();

    res.json({
      success: true,
      message: `Deleted ${count} user(s) from memory`,
      count: count
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to clear users" });
  }
});

// API: Get deployment wallet (for development/testing only)
app.get("/api/deployment-wallet", (req, res) => {
  try {
    const privateKey = process.env.PRIVATE_KEY;

    if (!privateKey) {
      return res.status(404).json({ error: "No deployment wallet configured" });
    }

    const wallet = new Wallet(privateKey);

    res.json({
      success: true,
      privateKey: privateKey,
      address: wallet.address
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to get deployment wallet" });
  }
});

// Health check
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "plasma-escrow-backend",
    contractDeployed: config.deployed,
    contractAddress: config.contractAddress,
    emailConfigured: !!resend
  });
});

app.listen(PORT, () => {
  console.log("╔════════════════════════════════════════════╗");
  console.log("║   🚀 Plasma Escrow Links Backend          ║");
  console.log("╚════════════════════════════════════════════╝");
  console.log("");
  console.log(`✅ Server running on http://localhost:${PORT}`);
  console.log(`✅ Contract deployed: ${config.deployed ? "Yes" : "No"}`);
  if (config.deployed) {
    console.log(`✅ Contract address: ${config.contractAddress}`);
  }
  console.log(`📧 Email service: ${resend ? "Enabled ✅" : "Disabled ⚠️  (set RESEND_API_KEY to enable)"}`);
  console.log("");
  console.log("📂 User data stored in:", USERS_DIR);
  console.log("🔐 Encryption enabled");
  console.log("");
  console.log("Ready to accept requests!");
});
