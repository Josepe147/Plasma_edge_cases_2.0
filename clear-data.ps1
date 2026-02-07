# Clear User Data - PowerShell Script
# This removes all user accounts but keeps your API key and config

Write-Host "========================================" -ForegroundColor Blue
Write-Host "   Clear User Data" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""
Write-Host "This will DELETE all user accounts and reset the database." -ForegroundColor Yellow
Write-Host "Your .env file (API keys) will be preserved." -ForegroundColor Green
Write-Host ""

if (Test-Path "data\users") {
    Write-Host "Current users will be PERMANENTLY DELETED:" -ForegroundColor Red
    Get-ChildItem "data\users\*.json" | ForEach-Object { Write-Host "  - $($_.BaseName)" }
} else {
    Write-Host "(No users found)" -ForegroundColor Gray
}

Write-Host ""
$confirm = Read-Host "Are you sure? Type YES to confirm"

if ($confirm -ne "YES") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Clearing user data..." -ForegroundColor Yellow

# Remove all user files
if (Test-Path "data\users") {
    Remove-Item "data\users\*.json" -Force -ErrorAction SilentlyContinue
    Write-Host "- Deleted all user accounts" -ForegroundColor Green
}

Write-Host ""
Write-Host "NOTE: Also clear your browser:" -ForegroundColor Yellow
Write-Host "  1. Press F12 (Developer Tools)"
Write-Host "  2. Go to Application or Storage tab"
Write-Host "  3. Click 'Clear site data' or 'Clear storage'"
Write-Host "  4. Or just use Incognito/Private mode"
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "   User Data Cleared!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now:" -ForegroundColor Cyan
Write-Host "  1. Register with the same usernames again"
Write-Host "  2. Start fresh with new accounts"
Write-Host "  3. Your .env file is safe (API keys preserved)"
Write-Host ""
