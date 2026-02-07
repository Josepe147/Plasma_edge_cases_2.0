@echo off
REM Plasma Escrow Links - Windows Startup Script

echo ========================================
echo    Plasma Escrow Links - Startup
echo ========================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Node.js is not installed
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

echo Node.js found
echo.

REM Install dependencies if needed
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    echo.
)

REM Create data directory if needed
if not exist "data" (
    echo Creating data directory...
    mkdir data\users
    echo.
)

REM Start the server
echo Starting backend server...
start /B node server.js
timeout /t 3 /nobreak >nul

REM Open browser
echo Opening browser...
start http://localhost:3000/

echo.
echo ========================================
echo    Plasma Escrow Links is Ready!
echo ========================================
echo.
echo Open in browser: http://localhost:3000/
echo.
echo Press any key to stop the server...
pause >nul

REM Kill node processes (warning: this kills ALL node processes)
taskkill /F /IM node.exe >nul 2>nul

echo Server stopped
