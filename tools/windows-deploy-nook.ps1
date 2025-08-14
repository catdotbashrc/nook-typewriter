# Windows Native Nook Deployment Script
# Run everything from Windows - no WSL required!
#
# Prerequisites (we'll help install these):
#   1. Rufus or Win32DiskImager - for writing images
#   2. 7-Zip - for extracting Linux archives
#   3. Docker Desktop - for building (optional)

Write-Host @"
═══════════════════════════════════════════════════════════════
     🏰 Nook Typewriter Windows Deployment Tool 📜
     Deploy directly from Windows - No WSL needed!
═══════════════════════════════════════════════════════════════
"@ -ForegroundColor Cyan

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Please run as Administrator!" -ForegroundColor Red
    Write-Host "   Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Running with Administrator privileges" -ForegroundColor Green
Write-Host ""

# Function to download files
function Download-Tool {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Destination
    )
    
    if (Test-Path $Destination) {
        Write-Host "  ✓ $Name already downloaded" -ForegroundColor Green
        return
    }
    
    Write-Host "  → Downloading $Name..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        Write-Host "  ✓ $Name downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Failed to download $Name" -ForegroundColor Red
        Write-Host "     Please download manually from: $Url" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Create tools directory
$ToolsDir = "$env:USERPROFILE\NookTools"
if (!(Test-Path $ToolsDir)) {
    Write-Host "Creating tools directory at $ToolsDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ToolsDir | Out-Null
}

Write-Host ""
Write-Host "Step 1: Installing Required Tools" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# Check for Rufus (portable version)
$RufusPath = "$ToolsDir\rufus.exe"
if (!(Test-Path $RufusPath)) {
    Write-Host "  → Downloading Rufus (USB/SD card writer)..." -ForegroundColor Yellow
    Download-Tool -Name "Rufus" `
                  -Url "https://github.com/pbatard/rufus/releases/download/v4.3/rufus-4.3p.exe" `
                  -Destination $RufusPath
}

# Check for Win32DiskImager as alternative
$DiskImagerPath = "$ToolsDir\Win32DiskImager.exe"
$DiskImagerUrl = "https://sourceforge.net/projects/win32diskimager/files/latest/download"

# Check for 7-Zip
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
if (!(Test-Path $SevenZipPath)) {
    Write-Host "  ⚠️ 7-Zip not found" -ForegroundColor Yellow
    Write-Host "     Install from: https://www.7-zip.org/" -ForegroundColor Cyan
    $has7zip = $false
} else {
    Write-Host "  ✓ 7-Zip found" -ForegroundColor Green
    $has7zip = $true
}

Write-Host ""
Write-Host "Step 2: Download Pre-Built Nook Image" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# For now, we'll help them build their own
Write-Host @"
  Since we don't have a pre-built image yet, you have two options:

  Option A: Use Docker Desktop (Recommended)
  ─────────────────────────────────────────
  1. Install Docker Desktop for Windows
  2. Build the image using Docker
  3. Export as .img file

  Option B: Use Pre-Built Image
  ────────────────────────────
  We'll help you create one!
"@ -ForegroundColor Yellow

Write-Host ""
Write-Host "Step 3: Detect SD Card" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# Get disk information using WMI
Write-Host "  → Scanning for removable drives..." -ForegroundColor Yellow
$RemovableDisks = Get-WmiObject Win32_DiskDrive | Where-Object {$_.MediaType -eq "Removable Media"}

if ($RemovableDisks.Count -eq 0) {
    Write-Host "  ⚠️ No SD cards detected!" -ForegroundColor Yellow
    Write-Host "     Please insert your SD card and run again" -ForegroundColor DarkGray
} else {
    Write-Host "  ✓ Found removable drives:" -ForegroundColor Green
    foreach ($disk in $RemovableDisks) {
        $size = [math]::Round($disk.Size / 1GB, 2)
        Write-Host "    → Disk $($disk.Index): $($disk.Model) - $size GB" -ForegroundColor Cyan
        
        # Get drive letter
        $partitions = Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition"
        foreach ($partition in $partitions) {
            $drives = Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass=Win32_LogicalDiskToPartition"
            foreach ($drive in $drives) {
                Write-Host "      Drive Letter: $($drive.DeviceID)" -ForegroundColor DarkGray
            }
        }
    }
}

Write-Host ""
Write-Host "Step 4: Create Bootable SD Card" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

Write-Host @"
  To write the Nook image to SD card:

  Using Rufus (Recommended):
  ─────────────────────────
  1. Run: $RufusPath
  2. Select your SD card (BE CAREFUL!)
  3. Select "Disk or ISO image"
  4. Browse to your .img file
  5. Click START

  Using Command Line (Advanced):
  ──────────────────────────────
  We can also use dd for Windows if you prefer
"@ -ForegroundColor Yellow

Write-Host ""
Write-Host "Step 5: Quick Image Builder (Experimental)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

$buildImage = Read-Host "Do you want to try building an image now? (y/n)"

if ($buildImage -eq 'y') {
    Write-Host ""
    Write-Host "Checking Docker Desktop..." -ForegroundColor Yellow
    
    try {
        $dockerVersion = docker --version
        Write-Host "  ✓ Docker found: $dockerVersion" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Building Nook image with Docker..." -ForegroundColor Yellow
        Write-Host "  This will take 10-15 minutes..." -ForegroundColor DarkGray
        
        # Create a batch file to run Docker commands
        $BuildScript = @"
@echo off
echo Building Nook Typewriter image...
cd /d %USERPROFILE%\projects\nook
docker build -t nook-writer --build-arg BUILD_MODE=writer -f build/docker/nookwriter-optimized.dockerfile .
docker create --name nook-export nook-writer
docker export nook-export -o nook-writer.tar
docker rm nook-export
echo Image exported to nook-writer.tar
echo Converting to IMG format...
pause
"@
        
        $BuildScriptPath = "$ToolsDir\build-nook.bat"
        Set-Content -Path $BuildScriptPath -Value $BuildScript
        
        Write-Host "  Build script created at: $BuildScriptPath" -ForegroundColor Green
        Write-Host "  Run this script to build the image" -ForegroundColor Yellow
        
    } catch {
        Write-Host "  ❌ Docker Desktop not found" -ForegroundColor Red
        Write-Host "     Install from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📋 Summary - Windows Deployment Process" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host @"

1. Tools Ready:
   ✓ Rufus: $RufusPath
   $(if ($has7zip) {"✓"} else {"❌"}) 7-Zip: Install if needed

2. SD Card:
   $(if ($RemovableDisks) {"✓ SD Card detected"} else {"❌ Insert SD card"})

3. Next Steps:
   a) Build image using Docker Desktop
   b) OR download a pre-built image
   c) Use Rufus to write image to SD card
   d) Insert SD card into Nook and boot!

Tools Directory: $ToolsDir

"@ -ForegroundColor White

Write-Host "Press Enter to open Rufus..." -ForegroundColor Yellow
Read-Host
if (Test-Path $RufusPath) {
    Start-Process $RufusPath
}