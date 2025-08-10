# Nook Writing System - Detailed Walkthrough

A complete guide for transforming your Nook Simple Touch into a dedicated Linux-based writing device. This guide assumes you're comfortable with technology but new to Linux.

## Table of Contents

1. [Understanding What We're Building](#understanding)
2. [Preparing Your Computer](#preparing)
3. [Understanding Docker's Role](#docker)
4. [Building Your Writing Environment](#building)
5. [Preparing Your Nook](#nook-prep)
6. [Creating the SD Card](#sd-card)
7. [First Boot and Testing](#first-boot)
8. [Customizing Your System](#customizing)
9. [Cloud Synchronization](#cloud-sync)
10. [Daily Usage](#daily-usage)
11. [Troubleshooting](#troubleshooting)

## Understanding What We're Building {#understanding}

### What Is This Project?

We're transforming a 2011 e-reader into a modern writing tool that:
- Runs a full Linux operating system (Alpine Linux)
- Provides a powerful text editor (Vim) optimized for writing
- Syncs your work to the cloud automatically
- Offers two specialized modes: note-taking and long-form writing
- Operates completely without distractions

### Why This Approach Works

The Nook Simple Touch has unique qualities that make it ideal for focused writing:
- **E-Ink display**: Easy on the eyes, readable in sunlight, no blue light
- **Week-long battery**: E-Ink only uses power when updating the screen
- **No distractions**: Too slow for web browsing, no notifications
- **Perfect constraints**: Limited resources enforce focused, single-purpose use

### What You'll Learn

This guide will teach you:
- Basic Linux concepts and commands
- How Docker simplifies complex software deployment
- How to work with SD cards and disk images
- How to customize a text editor for your writing needs
- How to set up automated cloud backups

## Preparing Your Computer {#preparing}

### Required Hardware

Before starting, gather these items:

1. **Nook Simple Touch (Model BNRV300)**
   - Check the back of your device for the model number
   - Firmware must be version 1.2.2 or earlier
   - Check firmware: Settings → Device Info → Software

2. **Two SD Cards (16-32GB)**
   - One for rooting/kernel installation
   - One for the Linux system (will become permanent)
   - Class 10 or better for decent performance
   - Brand matters: SanDisk or Samsung recommended

3. **USB OTG Cable**
   - Micro-USB to USB-A female adapter
   - Allows connecting a keyboard to the Nook
   - Buy two - they're fragile and you need a backup

4. **USB Keyboard**
   - Simple, wired keyboard (no RGB, no extra features)
   - Low power consumption is critical
   - Older models (2010-2012) work best

### Installing Docker

Docker lets us build the entire system on your fast computer, then transfer it to the Nook. Think of it as a virtual Linux computer running inside your main computer.

#### On Windows:

1. Download Docker Desktop from docker.com
2. Run the installer (requires Windows 10/11 Pro or Home with WSL2)
3. Restart your computer when prompted
4. Launch Docker Desktop and wait for it to start
5. Open PowerShell and verify:
   ```powershell
   docker --version
   # Should show: Docker version 24.x.x or higher
   ```

#### On macOS:

1. Download Docker Desktop for Mac from docker.com
2. Open the .dmg file and drag Docker to Applications
3. Launch Docker from Applications
4. Grant permissions when prompted
5. Open Terminal and verify:
   ```bash
   docker --version
   ```

#### On Linux:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
# Log out and back in

# Fedora
sudo dnf install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### Installing Other Tools

#### Git (for downloading our configurations):

**Windows**: Download Git from git-scm.com
**macOS**: Install via Homebrew: `brew install git`
**Linux**: `sudo apt install git` or `sudo dnf install git`

#### SD Card Software:

**Windows**: Download Win32DiskImager or Rufus
**macOS**: Built-in `dd` command (we'll show you how)
**Linux**: Built-in `dd` command

## Understanding Docker's Role {#docker}

### What Is Docker?

Docker is like a recipe system for computers. Instead of installing software piece by piece, Docker lets us describe everything we want in a "recipe" (Dockerfile), then automatically builds the complete system. This ensures everyone gets exactly the same result.

### Why Use Docker Here?

Traditional approach problems:
- Installing software on the Nook is painfully slow (800MHz processor)
- Compiling programs could take hours or fail entirely
- One mistake might break everything, requiring starting over
- No way to share exact configurations with others

Docker solution:
- Build everything on your fast computer (takes minutes)
- Test configurations instantly
- Make mistakes safely (just rebuild)
- Share your exact setup with others
- Version control your entire system

### How It Works

1. We write a Dockerfile describing what we want
2. Docker builds a virtual Alpine Linux system
3. We configure everything inside Docker
4. We export the entire system as a single file
5. We copy that file to an SD card
6. The Nook boots directly from our pre-configured system

## Building Your Writing Environment {#building}

### Getting the Configuration Files

First, we'll download all the pre-made configurations from the community repository:

```bash
# Open Terminal (Mac/Linux) or PowerShell (Windows)
cd Desktop
git clone https://github.com/community/nook-writing-system
cd nook-writing-system
```

This downloads:
- The Dockerfile (system recipe)
- Vim configurations for writing
- Menu scripts for the Nook
- Cloud sync scripts

### Understanding the Dockerfile

Let's examine what we're building. Open `Dockerfile` in any text editor:

```dockerfile
FROM alpine:3.17 AS builder
```
This line says "start with Alpine Linux version 3.17 as our base." Alpine is a tiny Linux distribution perfect for limited hardware.

```dockerfile
RUN apk add --no-cache \
    build-base git cmake \
    linux-headers ncurses-dev
```
This installs tools needed to compile software. We compile on your fast computer, not the slow Nook.

```dockerfile
# Build FBInk
RUN git clone --depth=1 https://github.com/NiLuJe/FBInk && \
    cd FBInk && \
    make MINIMAL=1 FONTS=1 && \
    make install
```
FBInk is special software that knows how to display text on E-Ink screens properly. Regular programs would show ghosting and artifacts.

```dockerfile
# Install packages
RUN apk add --no-cache \
    vim rsync rclone openssh-client \
    git tmux ncurses bash curl wget
```
These are the actual programs we'll use:
- **vim**: Our text editor
- **rsync/rclone**: For cloud synchronization
- **bash**: Command interpreter
- Others: Supporting utilities

### Building the System

Now we build our complete Linux system:

```bash
# Make sure you're in the nook-writing-system directory
docker build -t nook-system .
```

What happens:
1. Docker downloads Alpine Linux (5MB)
2. Installs all software (~45MB total)
3. Compiles FBInk for E-Ink support
4. Configures Vim with writing modes
5. Sets up the menu system

This takes 5-10 minutes. You'll see lots of text scrolling by - that's normal.

### Exporting the System

Once built, we export our system as a single file:

```bash
# Create a container from our image
docker create --name nook-export nook-system

# Export it as a compressed file
docker export nook-export | gzip > nook-alpine.tar.gz

# Clean up
docker rm nook-export

# Check the file size (should be ~50MB)
ls -lh nook-alpine.tar.gz
```

You now have a complete Linux system in a single file!

## Preparing Your Nook {#nook-prep}

### Understanding the Process

We need to modify the Nook in two stages:
1. **Rooting**: Gain administrator access to install custom software
2. **Kernel modification**: Enable USB support for keyboards

Both modifications are reversible and well-tested by the community.

### Stage 1: Rooting with NookManager

#### Downloading NookManager

```bash
# Download the rooting tool
wget https://archive.org/download/nook-manager/NookManager.img

# Verify the download (should be ~73MB)
ls -lh NookManager.img
```

#### Writing to SD Card

**On Windows:**
1. Insert SD card
2. Open Win32DiskImager as Administrator
3. Select `NookManager.img` as Image File
4. Select your SD card drive letter
5. Click "Write" and confirm
6. Wait for "Write Successful"

**On Mac/Linux:**
```bash
# Find your SD card device
# Mac:
diskutil list
# Linux:
lsblk

# Write the image (replace sdX with your device)
# Mac example:
sudo dd if=NookManager.img of=/dev/disk2 bs=4m
# Linux example:
sudo dd if=NookManager.img of=/dev/sdb bs=4M status=progress

# Ensure all data is written
sync
```

#### Rooting Process

1. **Fully charge your Nook** (important - don't let it die during rooting)

2. **Power off the Nook completely**
   - Hold power button for 5 seconds
   - Tap "Power off"

3. **Insert the NookManager SD card**

4. **Power on the Nook**
   - The Nook logo appears briefly
   - Then NookManager menu appears (different from normal startup)

5. **Create a backup first** (important!)
   - Touch "Backup and Restore"
   - Touch "Backup Device"
   - Wait 5-10 minutes (creates safety backup)

6. **Root the device**
   - Return to main menu
   - Touch "Root"
   - Touch "Root my Device"
   - Wait 2-3 minutes

7. **Success!**
   - Touch "Exit"
   - Remove SD card when prompted
   - Nook reboots normally but now has root access

### Stage 2: Installing USB Support

#### Preparing the Kernel Installation

```bash
# Download recovery tool and kernel
wget https://archive.org/download/cwm-nook/CWM-Recovery.img
wget https://archive.org/download/nook-kernels/kernel-176-usb-host.zip

# Write CWM to SD card (same process as before)
sudo dd if=CWM-Recovery.img of=/dev/sdX bs=4M
sync

# Mount the SD card and copy kernel
sudo mkdir /mnt/sdcard
sudo mount /dev/sdX1 /mnt/sdcard
sudo cp kernel-176-usb-host.zip /mnt/sdcard/
sudo umount /mnt/sdcard
```

#### Installing the Kernel

1. Power off Nook
2. Insert SD card with CWM and kernel
3. Power on - CWM Recovery appears
4. Navigate with volume buttons (or touch):
   - Select "install zip from sdcard"
   - Select "choose zip from sdcard"
   - Select "kernel-176-usb-host.zip"
   - Select "Yes - Install"
5. Wait for "Install complete"
6. Select "reboot system now"
7. Remove SD card when prompted

Your Nook now supports USB keyboards!

## Creating the SD Card {#sd-card}

### Understanding the Setup

We'll create a special SD card that contains:
- A small boot partition (100MB) for startup files
- A large root partition (rest of card) for Linux and your writing

This SD card becomes permanent - the Nook will always boot from it.

### Partitioning the SD Card

This erases everything on the SD card. Make sure you're using the right one!

```bash
# Start the partition tool
sudo fdisk /dev/sdX  # Replace sdX with your device

# You'll see: Command (m for help):
# Type these commands in order:

o          # Create new partition table
[Enter]    # Confirm

n          # New partition
p          # Primary partition  
1          # Partition number 1
[Enter]    # Default first sector
+100M      # 100MB size

t          # Change partition type
c          # W95 FAT32 type

n          # New partition
p          # Primary partition
2          # Partition number 2  
[Enter]    # Default first sector
[Enter]    # Use rest of disk

w          # Write changes and exit
```

### Formatting the Partitions

```bash
# Format boot partition as FAT32
sudo mkfs.vfat -F 32 -n BOOT /dev/sdX1

# Format root partition as F2FS (optimized for flash)
sudo mkfs.f2fs -l ROOT /dev/sdX2

# If f2fs-tools not installed:
sudo apt install f2fs-tools  # Ubuntu/Debian
sudo dnf install f2fs-tools  # Fedora
```

### Installing Alpine Linux

```bash
# Create mount points
sudo mkdir -p /mnt/boot /mnt/root

# Mount partitions
sudo mount /dev/sdX1 /mnt/boot
sudo mount /dev/sdX2 /mnt/root

# Extract our system
sudo tar -xzf nook-alpine.tar.gz -C /mnt/root/

# Show progress (this takes 2-3 minutes)
ls -la /mnt/root/
```

### Configuring Boot

The Nook needs specific instructions to boot Linux:

```bash
# Create boot configuration
sudo nano /mnt/boot/uEnv.txt
```

Type exactly:
```
bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M quiet
bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
```

Save with Ctrl+X, Y, Enter.

```bash
# Copy kernel to boot partition
sudo cp /mnt/root/boot/uImage /mnt/boot/

# Verify files are there
ls -la /mnt/boot/
# Should show: uEnv.txt and uImage

# Unmount safely
sudo umount /mnt/boot /mnt/root
```

## First Boot and Testing {#first-boot}

### The Moment of Truth

1. **Insert the SD card into your Nook**
2. **Connect your USB keyboard via the OTG cable**
3. **Power on the Nook**

What you'll see:
- Nook logo (5 seconds)
- Black screen (10 seconds - kernel loading)
- "NOOK WRITING SYSTEM" menu appears

If the menu doesn't appear after 30 seconds, see [Troubleshooting](#troubleshooting).

### Testing Basic Functions

#### Test 1: Keyboard Detection

Press any key. The menu should respond. If not:
- Check OTG cable connection
- Try a different keyboard
- May need a powered USB hub

#### Test 2: Menu Navigation

The main menu shows:
```
[Z] Zettelkasten Mode
[D] Drafting Mode  
[R] Resume Last Session
[M] Maintenance
[S] Shutdown
```

Press 'Z' to enter note-taking mode.

#### Test 3: Vim Basics

You're now in Vim. If you've never used Vim:

1. Press `i` to enter INSERT mode (you can now type)
2. Type some test text
3. Press `Esc` to leave INSERT mode
4. Type `:w test.txt` and press Enter (saves file)
5. Type `:q` and press Enter (quits Vim)

### Understanding the Modes

#### Zettelkasten Mode (Notes)

Optimized for quick note capture:
- Creates timestamped notes automatically
- Easy linking between notes
- Fast searching across all notes
- Minimal interface for focus

Try it:
```
Press: Space z n    (creates new timestamped note)
Type: i             (enter insert mode)
Write: This is my first note!
Press: Esc          (leave insert mode)  
Type: :w Enter      (save)
Type: :q Enter      (quit)
```

#### Drafting Mode (Long-form)

Optimized for continuous writing:
- Soft line wrapping for prose
- Limited backward editing (maintains flow)
- Centered text column
- Minimal distractions

Try it:
```
Press: Space d           (enter draft mode)
Type: :e chapter1.txt    (create new file)
Type: i                  (insert mode)
Write your text...
```

## Customizing Your System {#customizing}

### Modifying Vim Settings

Your preferences might differ from the defaults. Here's how to customize:

#### On your computer (rebuild method):

```bash
# Edit the vim configuration
nano config/vimrc

# Some settings to consider:
set textwidth=72      # Line length (0 = no limit)
set tabstop=4        # Tab width
set expandtab        # Use spaces not tabs
set spell            # Enable spell checking
colorscheme desert   # Change color scheme

# Rebuild the Docker image
docker build -t nook-system .

# Re-export and redeploy to SD card
```

#### Directly on the Nook:

```bash
# In the Nook menu, press M for Maintenance
# Then:
vi ~/.vimrc

# Make changes, save with :w, quit with :q
# Changes apply immediately
```

### Adding Custom Scripts

Want to add your own functionality?

```bash
# On your computer, create a new script
nano config/scripts/my-script.sh

#!/bin/sh
echo "My custom script!"
# Your code here

# Make it executable
chmod +x config/scripts/my-script.sh

# Rebuild Docker image - script is now included
```

### Customizing the Menu

Edit `config/scripts/nook-menu.sh`:

```bash
# Add new menu option
fbink -y 11 "[C] Custom Option"

# Add handler in case statement
c|C)
    /usr/local/bin/my-script.sh
    ;;
```

## Cloud Synchronization {#cloud-sync}

### Understanding Sync Options

Two approaches available:

1. **Rclone** (recommended): Works with 70+ cloud services
2. **Rsync**: For your own server via SSH

### Setting Up Rclone

#### On the Nook:

1. Enable WiFi first:
```bash
# Press M for Maintenance
vi /etc/network/interfaces

# Uncomment and edit:
auto wlan0
iface wlan0 inet dhcp
    wireless-ssid "Your-WiFi-Name"
    wireless-psk "Your-Password"

# Save and exit
:wq

# Start networking
rc-service networking start
```

2. Configure Rclone:
```bash
rclone config

# Follow prompts:
n) New remote
name> dropbox
Storage> dropbox
# Follow authorization flow
```

3. Test sync:
```bash
# Upload notes
rclone sync ~/notes dropbox:nook-notes

# Download notes
rclone sync dropbox:nook-notes ~/notes
```

### Automated Sync

The system includes a sync script:

```bash
# Manual sync anytime
sync-notes

# Or create automatic sync on shutdown
# Edit /usr/local/bin/nook-menu.sh
# Add before poweroff:
/usr/local/bin/sync-notes
```

### Privacy Consideration

Sync only when needed:
- Keep WiFi disabled normally (saves battery, maintains focus)
- Enable only for sync sessions
- Consider encrypting sensitive notes

## Daily Usage {#daily-usage}

### A Typical Writing Session

#### Morning Pages Workflow

1. Power on Nook (20 seconds to menu)
2. Press 'D' for Draft mode
3. Vim opens with yesterday's file
4. Press 'G' to go to end
5. Press 'o' for new line and start writing
6. Write for 30 minutes without editing
7. Press Esc, then `:w` to save
8. Press Space-q to return to menu

#### Research Notes Workflow

1. Press 'Z' for Zettelkasten mode
2. Press Space-zn for new timestamped note
3. Write your thought/observation
4. Create link to related note: `[[20240115-concept]]`
5. Press Space-zf while on link to follow it
6. Press Space-zb to go back
7. Build web of connected ideas

#### End of Day Backup

1. Press 'M' for Maintenance
2. Choose 'Enable WiFi'
3. Run 'sync-notes'
4. Verify "Sync complete"
5. Disable WiFi
6. Shutdown

### Battery Management

Expect 5-7 days of battery life with:
- 2-3 hours writing daily
- WiFi disabled
- Minimal screen refreshes

Extend battery:
- Use partial refresh during drafting
- Full refresh only when needed (fbink -s)
- Keep WiFi off except for sync
- Reduce screen updates in Vim settings

### File Organization

Suggested structure:
```
~/notes/           # Zettelkasten notes
  20240115143022-idea.md
  20240115150135-response.md
  
~/drafts/          # Long-form writing
  novel/
    chapter01.txt
    chapter02.txt
  essays/
    essay-topic.txt
    
~/journal/         # Daily entries
  2024-01-15.txt
  2024-01-16.txt
```

## Troubleshooting {#troubleshooting}

### Common Issues and Solutions

#### "Nook won't boot Linux"

**Symptom**: Stuck on Nook logo or black screen

**Solutions**:
1. Verify uImage exists in boot partition
2. Check uEnv.txt has correct syntax (no Windows line endings)
3. Try different SD card
4. Ensure kernel modification was successful

#### "Keyboard not detected"

**Symptom**: Menu appears but keyboard doesn't work

**Solutions**:
1. Test with different keyboard (older = better)
2. Check OTG cable (try another)
3. Use powered USB hub between Nook and keyboard
4. Verify kernel has USB host support (check dmesg)

#### "Screen has ghosting"

**Symptom**: Previous text visible behind current text

**Solutions**:
```bash
# Force full refresh
fbink -s

# In Vim, adjust settings
:set lazyredraw
:redraw!
```

#### "Out of memory errors"

**Symptom**: Vim crashes or system sluggish

**Reality**: With 200MB free, this is rare

**Solutions**:
```bash
# Check memory usage
free -m

# Close unnecessary buffers in Vim
:ls           # List buffers
:bd 3         # Delete buffer 3

# Restart Vim to clear everything
:qa!          # Quit all
```

#### "Can't connect to WiFi"

**Symptom**: Network won't start

**Solutions**:
```bash
# Check configuration
cat /etc/network/interfaces

# View connection attempts
dmesg | grep wlan

# Try manual connection
ifconfig wlan0 up
iwlist wlan0 scan
wpa_supplicant -i wlan0 -c /etc/wpa_supplicant.conf
```

#### "Files disappeared"

**Symptom**: Can't find your writing

**Prevention**:
- Always save before shutdown (`:w`)
- Use sync-notes regularly
- Keep backups on computer

**Recovery**:
```bash
# Check if files are elsewhere
find / -name "*.txt" 2>/dev/null
find / -name "*.md" 2>/dev/null

# Check if SD card corrupted
fsck.f2fs /dev/mmcblk0p2
```

### Getting Help

If stuck:

1. **Check the logs**:
```bash
dmesg                    # Kernel messages
cat /var/log/messages   # System log
```

2. **Community resources**:
- XDA-Developers Nook forum
- /r/ereader subreddit
- GitHub issues on project page

3. **Reset options**:
- Restore NookManager backup
- Reflash kernel
- Start fresh with new SD card

### Performance Optimization

If system feels slow:

```bash
# Reduce Vim features temporarily
:set nocursorline
:set norelativenumber
:set lazyredraw

# Clear caches
sync && echo 3 > /proc/sys/vm/drop_caches

# Check what's using memory
ps aux | head -20
```

## Conclusion

You've successfully transformed your Nook into a powerful, distraction-free writing tool. The system you've built:

- Runs a full Linux operating system
- Provides professional writing tools
- Syncs to modern cloud services
- Respects your focus and attention
- Lasts a week on battery

### Next Steps

1. **Practice Vim**: It has a learning curve but becomes incredibly efficient
2. **Customize further**: Adjust settings as you discover your preferences
3. **Share improvements**: Contribute configurations back to the community
4. **Write**: The tool is ready; now create!

### Remember

This device is intentionally limited. Those limitations are features:
- No web browser = no distractions
- Slow processor = can't multitask
- E-Ink screen = easy on eyes
- Simple interface = focus on words

Embrace the constraints. Let them guide you to deeper, more focused work.

Happy writing!