# Windows 11 PowerShell Script for SD Card USB Passthrough to WSL
# Run as Administrator
# 
# This script helps attach your SD card reader to WSL for Nook deployment

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "     Nook Typewriter SD Card Attach Helper for WSL" -ForegroundColor Yellow
Write-Host "     Preparing thy writing device for deployment" -ForegroundColor Yellow  
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Running with Administrator privileges" -ForegroundColor Green
Write-Host ""

# Check if usbipd is installed
try {
    $usbipdVersion = usbipd --version 2>$null
    Write-Host "✓ USBIPD-WIN detected: $usbipdVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ USBIPD-WIN not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing USBIPD-WIN..." -ForegroundColor Yellow
    
    # Try to install via winget
    try {
        winget install --interactive --exact dorssel.usbipd-win
        Write-Host "✓ USBIPD-WIN installed successfully" -ForegroundColor Green
        Write-Host "⚠️  You may need to restart this script after installation" -ForegroundColor Yellow
    } catch {
        Write-Host "Failed to install automatically." -ForegroundColor Red
        Write-Host "Please install manually from:" -ForegroundColor Yellow
        Write-Host "https://github.com/dorssel/usbipd-win/releases" -ForegroundColor Cyan
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "→ Scanning for USB devices..." -ForegroundColor Yellow
Write-Host ""

# List all USB devices
$devices = usbipd list

# Display devices
Write-Host "Available USB Devices:" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host $devices
Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray

# Look for common SD card reader patterns
Write-Host ""
Write-Host "🔍 Looking for SD card readers..." -ForegroundColor Yellow

$sdCardPatterns = @(
    "*Card Reader*",
    "*SD*Reader*", 
    "*Mass Storage*",
    "*USB Storage*",
    "*Generic*Storage*",
    "*Realtek*",
    "*Kingston*",
    "*SanDisk*"
)

$possibleDevices = @()
foreach ($line in ($devices -split "`n")) {
    foreach ($pattern in $sdCardPatterns) {
        if ($line -like $pattern) {
            if ($line -match '(\d+-\d+)') {
                $busid = $matches[1]
                $possibleDevices += [PSCustomObject]@{
                    BusID = $busid
                    Description = $line.Trim()
                }
                Write-Host "  → Found possible SD reader: $busid" -ForegroundColor Green
                Write-Host "    $($line.Trim())" -ForegroundColor DarkGray
            }
        }
    }
}

if ($possibleDevices.Count -eq 0) {
    Write-Host "⚠️  No SD card readers auto-detected" -ForegroundColor Yellow
    Write-Host "   Your device might have a different name" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Ask user to select device
if ($possibleDevices.Count -eq 1) {
    $selectedBusID = $possibleDevices[0].BusID
    Write-Host "Auto-selected device: $selectedBusID" -ForegroundColor Green
    $confirm = Read-Host "Use this device? (Y/n)"
    if ($confirm -eq 'n' -or $confirm -eq 'N') {
        $selectedBusID = Read-Host "Enter the BUSID of your SD card reader (e.g., 2-4)"
    }
} elseif ($possibleDevices.Count -gt 1) {
    Write-Host "Multiple possible devices found!" -ForegroundColor Yellow
    for ($i = 0; $i -lt $possibleDevices.Count; $i++) {
        Write-Host "$($i+1). $($possibleDevices[$i].BusID) - $($possibleDevices[$i].Description)"
    }
    $selection = Read-Host "Select device number or enter BUSID manually"
    
    if ($selection -match '^\d+$' -and [int]$selection -le $possibleDevices.Count) {
        $selectedBusID = $possibleDevices[[int]$selection - 1].BusID
    } else {
        $selectedBusID = $selection
    }
} else {
    $selectedBusID = Read-Host "Enter the BUSID of your SD card reader (e.g., 2-4)"
}

# Validate BUSID format
if ($selectedBusID -notmatch '^\d+-\d+$') {
    Write-Host "❌ Invalid BUSID format. Expected format: X-Y (e.g., 2-4)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "📎 Attaching device $selectedBusID to WSL..." -ForegroundColor Yellow

# First bind the device
try {
    Write-Host "  → Binding device..." -ForegroundColor DarkGray
    $bindResult = usbipd bind --busid $selectedBusID 2>&1
    
    # Check if already bound (not an error)
    if ($bindResult -like "*already shared*") {
        Write-Host "  ✓ Device already bound" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Device bound successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Bind warning: $_" -ForegroundColor Yellow
}

# Attach to WSL
try {
    Write-Host "  → Attaching to WSL..." -ForegroundColor DarkGray
    usbipd attach --wsl --busid $selectedBusID
    Write-Host "  ✓ Device attached to WSL successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to attach device: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "1. Make sure WSL2 is running" -ForegroundColor DarkGray
    Write-Host "2. Try: wsl --shutdown, then restart WSL" -ForegroundColor DarkGray
    Write-Host "3. Ensure the SD card is inserted" -ForegroundColor DarkGray
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ SD Card Reader attached to WSL!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps in WSL:" -ForegroundColor Yellow
Write-Host "1. Open WSL terminal" -ForegroundColor White
Write-Host "2. Run: ${Green}cd ~/projects/personal/nook${White}" -ForegroundColor White
Write-Host "3. Run: ${Green}./tools/wsl-mount-usb.sh${White}" -ForegroundColor White
Write-Host ""
Write-Host "To detach later, run:" -ForegroundColor DarkGray
Write-Host "  usbipd detach --busid $selectedBusID" -ForegroundColor Cyan
Write-Host ""

# Offer to open WSL
$openWSL = Read-Host "Open WSL now? (Y/n)"
if ($openWSL -ne 'n' -and $openWSL -ne 'N') {
    Write-Host "Opening WSL..." -ForegroundColor Green
    Start-Process wsl -ArgumentList "cd ~/projects/personal/nook && echo 'Ready to mount SD card!' && echo 'Run: ./tools/wsl-mount-usb.sh' && exec bash"
}

Write-Host ""
Write-Host "May thy digital quill write many tales! 📜" -ForegroundColor Magenta