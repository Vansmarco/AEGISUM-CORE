# Aegisum Core macOS Installation Guide

This guide will help you install and run the Aegisum Core wallet on macOS, providing the same functionality as the Windows and Linux versions.

## 🎯 Quick Start

### For End Users (Recommended)

1. **Download the DMG file** from the releases page
2. **Double-click** `Aegisum-Core-macOS.dmg` to mount it
3. **Drag** `Aegisum-Qt.app` to your Applications folder
4. **Launch** from Applications or Launchpad
5. **Allow network access** when prompted by macOS

### For Developers

```bash
git clone https://github.com/Vansmarco/AEGISUM-CORE.git
cd AEGISUM-CORE/aegisum-core-main
./make-macos-wallet.sh
```

## 📋 System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **macOS Version** | 10.14 (Mojave) | 11.0+ (Big Sur) |
| **Architecture** | Intel 64-bit | Intel/Apple Silicon |
| **RAM** | 4 GB | 8 GB+ |
| **Storage** | 2 GB free | 10 GB+ (for full node) |
| **Network** | Internet connection | Broadband |

## 🛠 Building from Source

### Prerequisites

1. **Install Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

2. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Automated Build

Use our comprehensive build script:

```bash
# Clone the repository
git clone https://github.com/Vansmarco/AEGISUM-CORE.git
cd AEGISUM-CORE/aegisum-core-main

# Make scripts executable
chmod +x *.sh

# Full build and deployment
./make-macos-wallet.sh

# Or with options:
./make-macos-wallet.sh --clean    # Clean build
./make-macos-wallet.sh --help     # Show all options
```

### Manual Build Process

If you prefer to build manually:

```bash
# Install dependencies
brew install automake libtool boost miniupnpc pkg-config python qt libevent qrencode fmt librsvg berkeley-db4 sqlite

# Generate build configuration
./autogen.sh

# Configure for macOS
./configure \
    --enable-reduce-exports \
    --disable-bench \
    --with-gui=qt5 \
    --enable-wallet

# Build (use all CPU cores)
make -j$(sysctl -n hw.ncpu)

# Create app bundle
make appbundle

# Create DMG for distribution
make deploy
```

## 📦 What Gets Built

### Main Application
- **Aegisum-Qt.app** - Complete GUI wallet application
- **Aegisum-Core-macOS.dmg** - Distribution disk image

### Command Line Tools (inside app bundle)
- **aegisumd** - Blockchain daemon
- **aegisum-cli** - Command line interface
- **aegisum-tx** - Transaction utility
- **aegisum-wallet** - Wallet management tool

## 🔧 Configuration

### Data Directory
```
~/Library/Application Support/Aegisum/
```

### Configuration File
Create: `~/Library/Application Support/Aegisum/aegisum.conf`

```ini
# Basic configuration
server=1
listen=1

# Network settings
port=39941
rpcport=39940

# Performance (adjust based on your Mac)
dbcache=1000
maxconnections=50

# For RPC access (advanced users)
rpcuser=your_username
rpcpassword=your_secure_password
rpcallowip=127.0.0.1
```

## 🚀 First Launch

### Initial Setup

1. **Launch the Application**
   - Open from Applications folder
   - Or use Spotlight: Press `Cmd+Space`, type "Aegisum"

2. **Security Prompt**
   - If you see "cannot be opened because the developer cannot be verified"
   - Right-click the app → "Open" → "Open" in the dialog
   - Or: System Preferences → Security & Privacy → "Open Anyway"

3. **Network Access**
   - Allow network connections when prompted
   - This is required for blockchain synchronization

4. **Data Directory Setup**
   - Choose default location (recommended)
   - Or select custom location for blockchain data

### Wallet Creation

1. **Create New Wallet**
   - File → Create Wallet
   - Choose a strong password
   - Enable encryption (recommended)

2. **Backup Immediately**
   - File → Backup Wallet
   - Save to secure location
   - Consider multiple backup locations

3. **Write Down Recovery Phrase**
   - If using HD wallet features
   - Store securely offline

## 🔐 Security Best Practices

### Wallet Security
- ✅ Use strong, unique passwords
- ✅ Enable wallet encryption
- ✅ Create regular backups
- ✅ Store backups securely offline
- ✅ Never share private keys

### macOS Security
- ✅ Keep macOS updated
- ✅ Use FileVault disk encryption
- ✅ Enable firewall
- ✅ Regular system backups

### Network Security
- ✅ Use secure networks
- ✅ Consider VPN for public WiFi
- ✅ Monitor network connections
- ✅ Use Tor if privacy is critical

## 🌐 Network Configuration

### Default Ports
- **P2P Network**: 39941
- **RPC Interface**: 39940 (localhost only)

### Firewall Configuration
Allow outbound connections on port 39941 for P2P networking.

### Proxy/Tor Setup
1. Settings → Network
2. Enable proxy
3. Configure SOCKS5 proxy (Tor: 127.0.0.1:9050)

## 🔧 Troubleshooting

### Common Issues

**App Won't Launch**
```bash
# Check if app is properly signed
codesign -dv /Applications/Aegisum-Qt.app

# Run from terminal to see errors
/Applications/Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt
```

**Slow Blockchain Sync**
- Check internet connection speed
- Ensure sufficient disk space
- Try different network/location
- Consider using bootstrap files

**High CPU/Memory Usage**
- Normal during initial sync
- Reduce `dbcache` in settings
- Close other applications
- Consider upgrading RAM

**Connection Issues**
```bash
# Test network connectivity
./aegisum-cli getconnectioncount

# Check peer connections
./aegisum-cli getpeerinfo
```

### Log Files
Check logs at:
```
~/Library/Application Support/Aegisum/debug.log
```

### Getting Help
- **GitHub Issues**: Report bugs and get support
- **Community Forums**: Join discussions
- **Documentation**: Check README files

## 🔄 Updating

### Automatic Updates
- The wallet will notify you of new versions
- Download from official releases page

### Manual Update
1. **Backup wallet first**
2. Download new DMG
3. Replace old app with new one
4. Launch and verify

### Preserving Data
- Wallet files are preserved during updates
- Blockchain data is preserved
- Settings are preserved

## 🎨 Customization

### Appearance
- **Dark Mode**: Follows macOS system setting
- **Font Size**: Adjustable in preferences
- **Language**: Multiple languages supported

### Interface
- **Toolbar**: Customizable buttons
- **Columns**: Show/hide transaction columns
- **Units**: Display in AEGS, mAEGS, or satoshis

## 📊 Performance Optimization

### For Different Mac Types

**MacBook Air/Entry Level**
```ini
dbcache=512
maxconnections=25
```

**MacBook Pro/iMac**
```ini
dbcache=2048
maxconnections=100
```

**Mac Pro/High-End**
```ini
dbcache=4096
maxconnections=200
```

### Storage Optimization
- Use SSD for blockchain data
- Enable pruning if space is limited
- Regular cleanup of old log files

## 🔌 Integration Features

### URL Scheme Support
The wallet handles `aegisum:` URLs:
```
aegisum:AegisumAddressHere?amount=1.0&label=Payment
```

### AppleScript Support
Basic automation support for advanced users.

### Dock Integration
- Shows sync progress
- Displays transaction notifications
- Quick access menu

## 📱 Advanced Features

### Multi-Wallet Support
- Run multiple wallets simultaneously
- Separate data directories
- Independent configurations

### Hardware Wallet Integration
- Ledger support
- Trezor support
- Enhanced security for large amounts

### Developer Tools
- RPC console
- Debug window
- Network traffic monitor

## 🎯 Aegisum-Specific Features

### Scrypt Mining
- Built-in mining support
- Pool mining configuration
- Solo mining options

### Network Specifications
- **Block Time**: 3 minutes
- **Algorithm**: Scrypt PoW
- **Block Reward**: 500 AEGS
- **Halving**: Every 100,000 blocks

### Address Format
- **Mainnet**: Starts with 'A'
- **Testnet**: Starts with '1'
- **Bech32**: Native SegWit support

---

## 📞 Support

### Community Resources
- **GitHub**: https://github.com/Vansmarco/AEGISUM-CORE
- **Issues**: Report bugs and request features
- **Discussions**: Community support and questions

### Documentation
- **README.md**: General project information
- **README-macOS.md**: Detailed macOS guide
- **Build Documentation**: Technical build instructions

---

**© 2024 Aegisum Core Development Team**

*Built with ❤️ for the macOS community*