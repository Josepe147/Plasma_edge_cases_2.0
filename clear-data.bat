@echo off
REM Clear User Data - Windows Script
REM This removes all user accounts but keeps your API key and config

echo ========================================
echo    Clear User Data
echo ========================================
echo.
echo This will DELETE all user accounts and reset the database.
echo Your .env file (API keys) will be preserved.
echo.
echo Current users will be PERMANENTLY DELETED:
if exist "data\users" (
    dir /b "data\users\*.json" 2>nul
) else (
    echo (No users found)
)
echo.
set /p CONFIRM="Are you sure? Type YES to confirm: "

if /i not "%CONFIRM%"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo Clearing user data...

REM Remove all user files
if exist "data\users" (
    del /q "data\users\*.json" 2>nul
    echo - Deleted all user accounts
)

REM Clear session storage note
echo.
echo NOTE: Also clear your browser:
echo   1. Press F12 (Developer Tools)
echo   2. Go to Application or Storage tab
echo   3. Click "Clear site data" or "Clear storage"
echo   4. Or just use Incognito/Private mode
echo.

echo ========================================
echo    User Data Cleared!
echo ========================================
echo.
echo You can now:
echo   1. Register with the same usernames again
echo   2. Start fresh with new accounts
echo   3. Your .env file is safe (API keys preserved)
echo.
pause
