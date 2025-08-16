# 🚀 Nook Boot Roadmap - The Practical Path

## Goal: Get JoKernel Running on Your Nook
*Time estimate: 2-3 hours if everything goes smoothly*

---

## 📋 Prerequisites Checklist
- [ ] Nook Simple Touch (working condition)
- [ ] MicroSD card (2GB minimum, 4GB recommended)
- [ ] SD card reader for your computer
- [ ] USB keyboard (to connect to Nook)
- [ ] USB OTG adapter (micro-USB to USB-A)
- [ ] Linux machine or WSL2 on Windows
- [ ] Docker installed and working

---

## 🎯 Phase 1: Quick Safety Check (5 mins)
**Don't skip this - it prevents bricking!**

```bash
# Run the safety test
cd /home/jyeary/projects/personal/nook
./tests/01-safety-check.sh

# If it fails, STOP and fix issues first
```

---

## 🔨 Phase 2: Build the Image (30 mins)

### Option A: Quick Build (Recommended for first boot)
```bash
# Build the minimal boot image
cd /home/jyeary/projects/personal/nook
docker build -t nook-mvp -f development/docker/minimal-boot.dockerfile .

# Export it
docker create --name temp-nook nook-mvp
docker export temp-nook | gzip > nook-mvp.tar.gz
docker rm temp-nook
```

### Option B: Full Writer Build (After you confirm boot works)
```bash
# Build the full writing environment
docker build -t nook-writer -f development/docker/nookwriter-optimized.dockerfile .

# Export it
docker create --name temp-writer nook-writer
docker export temp-writer | gzip > nook-writer.tar.gz
docker rm temp-writer
```

---

## 💾 Phase 3: Prepare SD Card (20 mins)

### Step 1: Find Your SD Card
```bash
# Insert SD card and find it
lsblk
# Look for something like /dev/sdb (BE CAREFUL - wrong device = data loss!)
```

### Step 2: Partition the SD Card
```bash
# Replace /dev/sdX with YOUR SD card device
export SDCARD=/dev/sdX  # DOUBLE CHECK THIS!

# Unmount if mounted
sudo umount ${SDCARD}* 2>/dev/null || true

# Create partitions
sudo parted ${SDCARD} --script mklabel msdos
sudo parted ${SDCARD} --script mkpart primary fat32 1MiB 50MiB
sudo parted ${SDCARD} --script mkpart primary ext4 50MiB 250MiB
sudo parted ${SDCARD} --script mkpart primary ext4 250MiB 100%
sudo parted ${SDCARD} --script set 1 boot on

# Format partitions
sudo mkfs.vfat -n BOOT ${SDCARD}1
sudo mkfs.ext4 -L rootfs ${SDCARD}2
sudo mkfs.ext4 -L data ${SDCARD}3
```

### Step 3: Copy Boot Files
```bash
# Mount boot partition
sudo mkdir -p /mnt/boot
sudo mount ${SDCARD}1 /mnt/boot

# Copy bootloader files (if you have them)
if [ -f firmware/boot/MLO ]; then
    sudo cp firmware/boot/MLO /mnt/boot/
    sudo cp firmware/boot/u-boot.bin /mnt/boot/
fi

# Copy kernel
if [ -f firmware/boot/uImage ]; then
    sudo cp firmware/boot/uImage /mnt/boot/
else
    echo "WARNING: No kernel found - build it first!"
fi

# Create boot script
cat << 'EOF' | sudo tee /mnt/boot/uEnv.txt
bootdelay=3
baudrate=115200
loadaddr=0x80008000
console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p2 rw
mmcrootfstype=ext4 rootwait
bootcmd=mmc rescan; fatload mmc 0 ${loadaddr} uImage; bootm ${loadaddr}
bootargs=console=${console} root=${mmcroot} rootfstype=${mmcrootfstype}
EOF

sudo umount /mnt/boot
```

### Step 4: Extract Root Filesystem
```bash
# Mount root partition
sudo mkdir -p /mnt/rootfs
sudo mount ${SDCARD}2 /mnt/rootfs

# Extract the filesystem
sudo tar -xzf nook-mvp.tar.gz -C /mnt/rootfs/

# Copy JesterOS scripts
sudo cp -r runtime/scripts/* /mnt/rootfs/usr/local/bin/
sudo cp -r runtime/configs/* /mnt/rootfs/etc/

# Set permissions
sudo chmod +x /mnt/rootfs/usr/local/bin/*.sh

# Clean up
sudo umount /mnt/rootfs
```

---

## 🎮 Phase 4: First Boot (10 mins)

### Step 1: Insert and Boot
1. Power off your Nook completely (hold power for 10 seconds)
2. Insert the SD card
3. Power on the Nook
4. **WAIT** - First boot takes 30-60 seconds

### Step 2: What You Should See
- Screen flashes white (bootloader)
- Penguin logo appears (kernel booting)
- Jester ASCII art shows up (JesterOS starting)
- Menu appears

### Step 3: Connect Keyboard
1. Plug USB keyboard into OTG adapter
2. Connect OTG adapter to Nook
3. Test by pressing number keys in menu

---

## 🚨 Phase 5: Troubleshooting

### Nothing Happens / Stock Nook Boots
- SD card not bootable - redo Phase 3
- Bootloader missing - check MLO and u-boot.bin
- Wrong partition flags - ensure partition 1 is bootable

### Kernel Panic / Boot Loop
```bash
# Check the safety test again
./tests/01-safety-check.sh

# Try the minimal image instead of full
# Use minimal-boot.dockerfile
```

### Black Screen After Boot
- Normal for E-Ink! Press a key
- Try: Hold 'n' + power button to force refresh
- USB keyboard might not be connected

### Can't Write/Save Files
```bash
# Remount root as read-write (from serial console or ssh)
mount -o remount,rw /
```

---

## ✅ Phase 6: Success Verification

If it worked, you should be able to:
1. See the Jester menu
2. Select "1" for writing mode
3. Type in Vim
4. Save a file (`:w test.txt`)
5. Exit back to menu

---

## 🎉 Next Steps (After Successful Boot)

1. **Build Full Version**: Use nookwriter-optimized.dockerfile
2. **Install to Internal Storage**: (Advanced - can brick device!)
3. **Customize Jester Moods**: Edit ASCII art in configs
4. **Add Your Vim Config**: Copy your .vimrc
5. **Write Something!**: That's what it's for!

---

## 🆘 Emergency Recovery

If you brick it (happens to everyone):
1. Remove SD card
2. Nook should boot normally to stock
3. If not, look up "Nook Simple Touch recovery" 
4. NookManager.img is your friend

---

## 💡 Pro Tips

- **Always** test on SD card first
- Keep a working SD card as backup
- The Nook is surprisingly hard to permanently brick
- Join the XDA Forums Nook Touch section for help
- Have fun - it's a hobby project!

---

*"By quill and candlelight, we boot!"* 🕯️📜