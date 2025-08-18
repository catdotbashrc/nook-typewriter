# Vanilla Debian Lenny 5.0 Docker Image

**Maintainers**: Justin Yeary and Persephone Raskova  
**Source**: https://github.com/bogdanscarwash/nook-typewriter (JesterOS Project)  
**Docker Hub**: `bogdanscarwash/debian-lenny`

## 🏛️ About

This is a **100% authentic Debian Lenny 5.0** Docker image built from the original packages available in February 2009. Perfect for:

- 🕹️ **Retro computing projects**
- 🧪 **Legacy software testing** 
- 📚 **Historical research**
- 🔧 **Embedded systems development**
- ⏰ **Period-correct development environments**

## 🚀 Quick Start

```bash
# Pull the image
docker pull bogdanscarwash/debian-lenny

# Run interactive session
docker run -it bogdanscarwash/debian-lenny

# Check the authentic environment
cat /etc/debian_version  # Shows: 5.0.10
uname -m                 # Shows: armv7l (ARMEL architecture)
```

## 📦 Installing Software

Use period-appropriate package management:

```bash
# Update package sources (connects to archive.debian.org)
apt-get update

# Install development tools (as they existed in 2009!)
apt-get install vim make git wget

# Install spell checking for writers
apt-get install aspell aspell-en

# Install system tools
apt-get install htop screen tree
```

## 🎯 Use Cases

### Retro Development Environment
```bash
# Perfect for experiencing 2009-era development
docker run -it -v $(pwd):/workspace bogdanscarwash/debian-lenny
cd /workspace
apt-get update && apt-get install make git vim
```

### Legacy Software Testing
```bash
# Test how your software behaves on 2009 systems
docker run -it --rm bogdanscarwash/debian-lenny
# Install and test your legacy applications
```

### Historical Research
```bash
# Explore what computing was like in 2009
docker run -it bogdanscarwash/debian-lenny
apt-get update && apt-get install fortunes cowsay
```

## 🏰 JesterOS Project

This image was created as part of the **JesterOS Project** - an initiative to transform old Nook e-readers into distraction-free typewriters. The project brings medieval whimsy to modern writing while preserving computing history.

**Learn more**: https://github.com/bogdanscarwash/nook-typewriter

## 📊 Technical Details

- **Base**: Debian Lenny 5.0.10 (February 2009)
- **Architecture**: ARMEL (ARM EABI Little Endian)
- **Size**: ~15MB compressed
- **Package Sources**: archive.debian.org (authentic 2009 packages)
- **Default Shell**: bash 3.2.39
- **Package Manager**: APT 0.7.x (2009 era)

## 🛠️ Building Locally

```bash
# Clone the JesterOS project
git clone https://github.com/bogdanscarwash/nook-typewriter
cd nook-typewriter

# Build the authentic Lenny rootfs (requires root)
sudo ./build/scripts/build-lenny-rootfs.sh

# Build the vanilla community image
./build/scripts/build-vanilla-lenny.sh --build-only
```

## 🤝 Contributing

Found issues? Want to improve the image? Contributions welcome!

1. Fork https://github.com/bogdanscarwash/nook-typewriter
2. Submit issues or pull requests
3. Help preserve computing history!

## 📜 License

Open source - help preserve computing history!

---

## 🏷️ Available Tags

- `latest` - Latest vanilla Lenny build
- `5.0.10` - Specific Debian version
- `lenny` - Named release tag

---

*"Preserving the digital heritage of 2009, one container at a time!"*

**Built with ❤️ by the JesterOS community**