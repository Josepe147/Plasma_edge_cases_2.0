# Plasma Escrow Links - PowerShell Startup Script
# Run with: .\start.ps1

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║   🚀 Plasma Escrow Links - Startup        ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org"
    exit 1
}

# Check if dependencies are installed
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
    Write-Host ""
}

# Check if data directory exists
if (-not (Test-Path "data")) {
    Write-Host "📁 Creating data directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "data\users" -Force | Out-Null
    Write-Host "✅ Data directory created" -ForegroundColor Green
    Write-Host ""
}

# Check if contract is deployed
$configFile = "data\config.json"
$deployed = $false

if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile | ConvertFrom-Json
        $deployed = $config.deployed
    } catch {
        $deployed = $false
    }
}

if (-not $deployed) {
    Write-Host "⚠️  Contract not yet deployed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You have two options:"
    Write-Host "  1. Deploy now (requires RPC_URL and PRIVATE_KEY)"
    Write-Host "  2. Deploy later through the web interface"
    Write-Host ""
    $deployNow = Read-Host "Deploy now? (y/n)"

    if ($deployNow -eq "y" -or $deployNow -eq "Y") {
        if (-not $env:RPC_URL) {
            $rpcInput = Read-Host "Enter RPC URL (default: https://testnet-rpc.plasma.to)"
            if ([string]::IsNullOrWhiteSpace($rpcInput)) {
                $env:RPC_URL = "https://testnet-rpc.plasma.to"
            } else {
                $env:RPC_URL = $rpcInput
            }
        }

        if (-not $env:PRIVATE_KEY) {
            $privateKey = Read-Host "Enter your private key (with 0x prefix)" -AsSecureString
            $env:PRIVATE_KEY = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($privateKey)
            )
        }

        Write-Host "🚀 Deploying contract..." -ForegroundColor Blue

        if (Get-Command forge -ErrorAction SilentlyContinue) {
            & .\deploy.bat
        } else {
            Write-Host "❌ Foundry not installed" -ForegroundColor Red
            Write-Host "Install Foundry from: https://book.getfoundry.sh/getting-started/installation"
            Write-Host "Or deploy later through the web interface"
        }
        Write-Host ""
    } else {
        Write-Host "ℹ️  Skipping deployment. You can deploy later." -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "✅ Contract already deployed" -ForegroundColor Green
    try {
        $config = Get-Content $configFile | ConvertFrom-Json
        Write-Host "   Address: $($config.contractAddress)" -ForegroundColor Green
    } catch {}
    Write-Host ""
}

# Start the backend server
Write-Host "🚀 Starting backend server..." -ForegroundColor Blue
$serverProcess = Start-Process -FilePath "node" -ArgumentList "server.js" -PassThru -WindowStyle Hidden

# Wait for server to start
Start-Sleep -Seconds 3

# Check if server is running
if (-not $serverProcess.HasExited) {
    Write-Host "✅ Backend server running (PID: $($serverProcess.Id))" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "❌ Failed to start server" -ForegroundColor Red
    exit 1
}

# Open browser
Write-Host "🌐 Opening browser..." -ForegroundColor Blue
Start-Sleep -Seconds 1
Start-Process "http://localhost:3000/"

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✨ Plasma Escrow Links is Ready!        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Open in browser: http://localhost:3000/" -ForegroundColor Green
Write-Host ""
Write-Host "Quick Links:" -ForegroundColor Yellow
Write-Host "  • Home:     http://localhost:3000/"
Write-Host "  • Login:    http://localhost:3000/login.html"
Write-Host "  • Register: http://localhost:3000/register.html"
Write-Host "  • Send XPL: http://localhost:3000/send.html"
Write-Host ""
Write-Host "Server is running in the background (PID: $($serverProcess.Id))" -ForegroundColor Yellow
Write-Host "To stop it, run: Stop-Process -Id $($serverProcess.Id)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or press any key to stop the server now..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop the server
Stop-Process -Id $serverProcess.Id -Force
Write-Host "✅ Server stopped" -ForegroundColor Green
