# Aegisum Core macOS Build Instructions

## 🚀 Quick Start

**Just run this one command:**

```bash
./build-macos-complete.sh
```

This script will:
- ✅ Install all dependencies via Homebrew
- ✅ Fix all compilation issues
- ✅ Build the complete Aegisum wallet
- ✅ Create a DMG installer
- ✅ Set up proper macOS app bundle

## 📋 What You Get

After successful build:

- **aegisumd** - Core daemon (runs the blockchain node)
- **aegisum-cli** - Command line interface
- **aegisum-tx** - Transaction creation tool  
- **aegisum-wallet** - Wallet management tool
- **aegisum-qt** - GUI wallet (if Qt build succeeds)
- **Aegisum-Core.dmg** - macOS installer package

## 🔧 Manual Build (if script fails)

### 1. Install Dependencies

```bash
brew install autoconf automake libtool pkg-config boost libevent berkeley-db@4 qt@5 miniupnpc libnatpmp qrencode protobuf sqlite
```

### 2. Set Environment

```bash
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/qt@5/lib -L/opt/homebrew/opt/berkeley-db@4/lib"
export CPPFLAGS="-I/opt/homebrew/opt/qt@5/include -I/opt/homebrew/opt/berkeley-db@4/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/qt@5/lib/pkgconfig"
export CXXFLAGS="-std=c++17 -Wno-suggest-override -Wno-deprecated-declarations"
export CFLAGS="-std=c++17"
```

### 3. Build

```bash
./autogen.sh
./configure --with-gui=qt5 --enable-wallet --with-sqlite=yes --with-qrencode --with-miniupnpc --with-natpmp CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS"
make -j$(sysctl -n hw.ncpu)
```

## 🐛 Troubleshooting

### Qt Errors
If you get Qt C++17 errors:
```bash
export CXXFLAGS="-std=c++17 -Wno-suggest-override"
```

### Boost Errors  
If you get Boost filesystem errors, the code has been patched to use newer APIs.

### Berkeley DB Errors
Make sure you have the correct version:
```bash
brew install berkeley-db@4
```

## 📱 Running the Wallet

### GUI Wallet
```bash
./src/qt/aegisum-qt
```

### Command Line
```bash
# Start daemon
./src/aegisumd -daemon

# Use CLI
./src/aegisum-cli getinfo
./src/aegisum-cli help
```

## 🎯 Features

Your macOS Aegisum wallet has the same features as Windows/Linux:

- ✅ Full blockchain node
- ✅ Wallet functionality  
- ✅ Transaction creation
- ✅ Address generation
- ✅ Balance checking
- ✅ Send/receive coins
- ✅ GUI interface (if built)
- ✅ RPC interface
- ✅ Same logos and branding

## 🔐 Security

The wallet includes all security features:
- HD wallet support
- Encrypted wallet files
- Backup/restore functionality
- Multi-signature support

## 📞 Support

If you encounter issues:
1. Check the build log for specific errors
2. Ensure all dependencies are installed
3. Try the manual build steps
4. Check macOS version compatibility (requires macOS 10.14+)

---

**🎉 Enjoy your Aegisum Core macOS wallet!**