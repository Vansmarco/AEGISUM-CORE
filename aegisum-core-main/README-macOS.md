# Aegisum Core - macOS Wallet

![Aegisum Logo](src/qt/res/icons/aegisum_splash.png)

Welcome to **Aegisum Core** for macOS! This is the official macOS wallet for the Aegisum cryptocurrency, providing the same features and security as the Windows and Linux versions.

## 🍎 macOS Features

- **Native macOS Application**: Fully integrated with macOS design guidelines
- **Retina Display Support**: Crisp, high-resolution interface on all Mac displays
- **macOS Notifications**: Native notification support for transactions and updates
- **Dock Integration**: Shows transaction status and progress in the Dock
- **Spotlight Search**: Find your wallet quickly with Spotlight
- **URL Scheme Support**: Handle `aegisum:` payment URLs from web browsers
- **Auto-Launch**: Option to start with macOS login

## 📋 System Requirements

- **macOS 10.14 (Mojave)** or later
- **64-bit Intel Mac** or **Apple Silicon Mac** (M1/M2)
- **4 GB RAM** minimum (8 GB recommended)
- **2 GB free disk space** for blockchain data
- **Internet connection** for blockchain synchronization

## 🚀 Quick Installation

### Option 1: Pre-built DMG (Recommended)
1. Download `Aegisum-Core-macOS.dmg` from the releases page
2. Double-click the DMG file to mount it
3. Drag `Aegisum-Qt.app` to your Applications folder
4. Launch from Applications or Launchpad

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/Vansmarco/AEGISUM-CORE.git
cd AEGISUM-CORE/aegisum-core-main

# Build for macOS
./build-macos.sh

# Create deployment package
./deploy-macos.sh
```

## 🔧 Building from Source

### Prerequisites
1. **Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (if not installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Build Process
The build process is automated with our custom script:

```bash
# Make scripts executable
chmod +x build-macos.sh deploy-macos.sh create-macos-icon.sh

# Build the wallet
./build-macos.sh
```

This will:
- Install all required dependencies via Homebrew
- Configure the build for macOS
- Compile all components
- Create the app bundle
- Generate a distributable DMG file

### Manual Build (Advanced)
If you prefer to build manually:

```bash
# Install dependencies
brew install automake libtool boost miniupnpc pkg-config python qt libevent qrencode fmt librsvg berkeley-db4 sqlite

# Generate build files
./autogen.sh

# Configure
./configure --enable-reduce-exports --disable-bench --with-gui=qt5

# Build
make -j$(sysctl -n hw.ncpu)

# Create app bundle
make appbundle

# Deploy
make deploy
```

## 🎯 What's Included

The macOS wallet package includes all the tools you need:

### GUI Wallet (`Aegisum-Qt.app`)
- **Full-featured wallet interface**
- **Transaction history and management**
- **Address book and labels**
- **Coin control features**
- **Backup and restore functionality**
- **Settings and preferences**

### Command Line Tools
Located in `Aegisum-Qt.app/Contents/MacOS/`:
- **`aegisumd`** - Blockchain daemon
- **`aegisum-cli`** - Command line interface
- **`aegisum-tx`** - Transaction utility
- **`aegisum-wallet`** - Wallet management tool

## 🔐 Security Features

### Code Signing
- The app is ad-hoc signed for local development
- For distribution, proper Apple Developer signing is recommended

### Gatekeeper Compatibility
- Built to work with macOS security features
- May require "Allow apps downloaded from: App Store and identified developers"

### Wallet Security
- **Encrypted wallet support** with strong passwords
- **Backup and recovery** options
- **Multi-signature support** for enhanced security
- **Hardware wallet integration** (Ledger, Trezor)

## 🌐 Network Configuration

### Default Ports
- **P2P Network**: 39941
- **RPC Interface**: 39940

### Data Directory
The wallet stores data in:
```
~/Library/Application Support/Aegisum/
```

### Configuration File
Create or edit: `~/Library/Application Support/Aegisum/aegisum.conf`

Example configuration:
```
# Network settings
listen=1
server=1

# RPC settings (for advanced users)
rpcuser=your_username
rpcpassword=your_secure_password
rpcallowip=127.0.0.1

# Performance settings
dbcache=1000
maxconnections=50
```

## 🚨 First Run Setup

1. **Launch the Application**
   - Open from Applications folder or Launchpad
   - Allow network connections when prompted

2. **Initial Blockchain Sync**
   - The wallet will download the blockchain (this may take several hours)
   - Progress is shown in the status bar
   - You can use the wallet while syncing

3. **Create or Import Wallet**
   - Create a new wallet with a strong password
   - Or import an existing wallet from backup

4. **Backup Your Wallet**
   - Go to File → Backup Wallet
   - Store the backup in a secure location
   - Consider multiple backup locations

## 🔧 Troubleshooting

### Common Issues

**"Aegisum-Qt.app" cannot be opened because the developer cannot be verified**
- Right-click the app and select "Open"
- Click "Open" in the security dialog
- Or go to System Preferences → Security & Privacy → General → "Open Anyway"

**Slow Blockchain Sync**
- Ensure stable internet connection
- Check available disk space
- Consider using bootstrap files for faster sync

**High CPU Usage**
- Normal during initial sync
- Reduce `dbcache` setting if needed
- Close other resource-intensive applications

**Connection Issues**
- Check firewall settings
- Ensure ports 39941 and 39940 are not blocked
- Try different network connection

### Getting Help

- **GitHub Issues**: [Report bugs and issues](https://github.com/Vansmarco/AEGISUM-CORE/issues)
- **Community Forums**: Join our community discussions
- **Documentation**: Check the main README.md for general information

## 🔄 Updating

### Automatic Updates
- The wallet will notify you of new versions
- Download updates from the official releases page

### Manual Update Process
1. Backup your wallet first
2. Download the new DMG file
3. Replace the old app with the new one
4. Launch and verify everything works

## 🎨 Customization

### Themes
- The wallet supports both Light and Dark modes
- Automatically follows macOS system appearance
- Manual theme selection available in preferences

### Interface
- Adjustable font sizes
- Customizable toolbar
- Multiple language support

## 📊 Performance Tips

### Optimize for Your Mac
- **SSD Storage**: Store blockchain data on SSD for better performance
- **RAM**: Increase `dbcache` setting if you have plenty of RAM
- **Network**: Use wired connection for initial sync if possible

### Resource Management
- Close wallet when not needed to save resources
- Use "Minimize to Dock" option to keep running in background
- Enable "Start with macOS" for always-on node operation

## 🔒 Privacy Features

- **Tor Support**: Route connections through Tor network
- **Proxy Settings**: Configure SOCKS proxy for enhanced privacy
- **Address Management**: Generate new addresses for each transaction
- **Coin Selection**: Manual coin control for privacy-conscious users

## 📱 Integration

### URL Schemes
The wallet registers the `aegisum:` URL scheme for payment links:
```
aegisum:AegisumAddressHere?amount=1.0&label=Payment
```

### AppleScript Support
Basic AppleScript automation support for advanced users.

### Spotlight Integration
The wallet and its data files are indexed by Spotlight for quick access.

---

## 🎯 About Aegisum

**Aegisum** is a secure, scalable, and community-driven blockchain built on Litecoin's foundation, optimized for high throughput and low fees.

### Our Mission
- **Crypto Safety & Awareness**: Educate users about crypto scams and rug pulls
- **Charity & Real Causes**: Support legitimate charitable causes

### Technical Specifications
- **Algorithm**: Scrypt Proof of Work
- **Block Time**: 3 minutes
- **Block Reward**: 500 AEGS
- **Total Supply**: 100,000,000 AEGS
- **Address Prefix**: A (mainnet), 1 (testnet)

---

**© 2024 Aegisum Core Development Team**

*This software is released under the MIT License. See LICENSE file for details.*