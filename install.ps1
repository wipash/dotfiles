# Set strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$CurrentExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($CurrentExecutionPolicy -ne "RemoteSigned") {
    Write-Host "🔒  Setting execution policy to RemoteSigned"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

Write-Host ""
Write-Host "🤚  This script will setup .dotfiles for you."
Write-Host "    Press any key to continue or Ctrl+C to abort..." -NoNewline
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "`n"

$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')

# Install PS7
$ps7Exists = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $ps7Exists) {
    Write-Host "🚀  Installing PowerShell 7"
    winget install -e --id Microsoft.PowerShell
}

# Install Scoop 
$scoopExists = Get-Command scoop -ErrorAction SilentlyContinue
if (-not $scoopExists) {
    Write-Host "🍨  Installing Scoop"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Install chezmoi
$chezmoiExists = Get-Command chezmoi -ErrorAction SilentlyContinue
if (-not $chezmoiExists) {
    Write-Host "👊  Installing chezmoi"
    winget install -e --id=twpayne.chezmoi
}

# Install Chocolatey
$chocoExists = Get-Command choco -ErrorAction SilentlyContinue
if (-not $chocoExists) {
    Write-Host "🍫  Installing Chocolatey"
    winget install -e --id=Chocolatey.Chocolatey
} else {
    choco upgrade chocolatey
}

# Install git
$gitExists = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitExists) {
    Write-Host "🐙  Installing git"
    winget install -e --id Git.Git
}

# Refresh path
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')

# Check if chezmoi is initialized
if (Test-Path "$env:USERPROFILE\.local\share\chezmoi\.git") {
    Write-Host "🚸  chezmoi already initialized"
    Write-Host "    Reinitialize with: 'chezmoi init https://github.com/wipash/dotfiles.git'"
}
else {
    Write-Host "🚀  Initialize dotfiles with:"
    Write-Host "    chezmoi init https://github.com/wipash/dotfiles.git"
}

Write-Host ""
Write-Host "Done."
