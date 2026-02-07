#!/bin/bash
# Plasma Escrow Links - Single Command Startup Script
# This script does everything: setup, deployment (if needed), and starts the app

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 Plasma Escrow Links - Startup        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js from https://nodejs.org"
    exit 1
fi

echo -e "${GREEN}✅ Node.js found: $(node --version)${NC}"

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Dependencies installed${NC}"
    echo ""
fi

# Check if data directory exists
if [ ! -d "data" ]; then
    echo -e "${YELLOW}📁 Creating data directory...${NC}"
    mkdir -p data/users
    echo -e "${GREEN}✅ Data directory created${NC}"
    echo ""
fi

# Check if contract is deployed
CONFIG_FILE="data/config.json"
DEPLOYED=false

if [ -f "$CONFIG_FILE" ]; then
    DEPLOYED=$(node -p "JSON.parse(require('fs').readFileSync('$CONFIG_FILE', 'utf8')).deployed" 2>/dev/null || echo "false")
fi

if [ "$DEPLOYED" = "false" ]; then
    echo -e "${YELLOW}⚠️  Contract not yet deployed${NC}"
    echo ""
    echo "You have two options:"
    echo "  1. Deploy now (requires RPC_URL and PRIVATE_KEY)"
    echo "  2. Deploy later through the web interface"
    echo ""
    read -p "Deploy now? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check for environment variables
        if [ -z "$RPC_URL" ]; then
            echo -e "${YELLOW}Enter RPC URL (default: https://testnet-rpc.plasma.to):${NC}"
            read -r RPC_INPUT
            export RPC_URL="${RPC_INPUT:-https://testnet-rpc.plasma.to}"
        fi

        if [ -z "$PRIVATE_KEY" ]; then
            echo -e "${YELLOW}Enter your private key (with 0x prefix):${NC}"
            read -r -s PRIVATE_KEY
            export PRIVATE_KEY
            echo ""
        fi

        echo -e "${BLUE}🚀 Deploying contract...${NC}"

        if command -v forge &> /dev/null; then
            ./deploy.sh || {
                echo -e "${YELLOW}⚠️  Deployment failed, but you can deploy later through the app${NC}"
            }
        else
            echo -e "${RED}❌ Foundry not installed${NC}"
            echo "Install Foundry from: https://book.getfoundry.sh/getting-started/installation"
            echo "Or deploy later through the web interface"
        fi
        echo ""
    else
        echo -e "${YELLOW}ℹ️  Skipping deployment. You can deploy later at: http://localhost:3000/admin.html${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✅ Contract already deployed${NC}"
    CONTRACT_ADDR=$(node -p "JSON.parse(require('fs').readFileSync('$CONFIG_FILE', 'utf8')).contractAddress" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}   Address: ${CONTRACT_ADDR}${NC}"
    echo ""
fi

# Start the backend server
echo -e "${BLUE}🚀 Starting backend server...${NC}"
node server.js &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Check if server is running
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo -e "${RED}❌ Failed to start server${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Backend server running (PID: $SERVER_PID)${NC}"
echo ""

# Open browser
OPEN_CMD=""
if command -v xdg-open &> /dev/null; then
    OPEN_CMD="xdg-open"
elif command -v open &> /dev/null; then
    OPEN_CMD="open"
elif command -v start &> /dev/null; then
    OPEN_CMD="start"
fi

if [ -n "$OPEN_CMD" ]; then
    echo -e "${BLUE}🌐 Opening browser...${NC}"
    sleep 1
    $OPEN_CMD "http://localhost:3000/" &>/dev/null || true
else
    echo -e "${YELLOW}ℹ️  Could not auto-open browser${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✨ Plasma Escrow Links is Ready!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Open in browser:${NC} http://localhost:3000/"
echo ""
echo -e "${YELLOW}Quick Links:${NC}"
echo "  • Home:     http://localhost:3000/"
echo "  • Login:    http://localhost:3000/login.html"
echo "  • Register: http://localhost:3000/register.html"
echo "  • Send XPL: http://localhost:3000/send.html"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Wait for server process
wait $SERVER_PID
