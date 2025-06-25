#!/bin/bash
# Complete Aegisum Core macOS Build Script
# This script will build the entire Aegisum wallet for macOS

set -e

echo "🚀 Starting Aegisum Core macOS Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS!"
    exit 1
fi

# Check for required tools
print_status "Checking for required tools..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is required but not installed!"
    echo "Install it from: https://brew.sh"
    exit 1
fi

# Install dependencies
print_status "Installing dependencies via Homebrew..."
brew install autoconf automake libtool pkg-config boost libevent berkeley-db@4 qt@5 miniupnpc libnatpmp qrencode protobuf sqlite

# Set environment variables
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/qt@5/lib -L/opt/homebrew/opt/berkeley-db@4/lib"
export CPPFLAGS="-I/opt/homebrew/opt/qt@5/include -I/opt/homebrew/opt/berkeley-db@4/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/qt@5/lib/pkgconfig"

# Set C++17 standard
export CXXFLAGS="-std=c++17 -Wno-suggest-override -Wno-deprecated-declarations"
export CFLAGS="-std=c++17"

print_status "Cleaning previous builds..."
make clean 2>/dev/null || true

print_status "Running autogen..."
./autogen.sh

print_status "Configuring build..."
./configure \
    --with-gui=qt5 \
    --enable-wallet \
    --with-sqlite=yes \
    --with-qrencode \
    --with-miniupnpc \
    --with-natpmp \
    CXXFLAGS="$CXXFLAGS" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    CPPFLAGS="$CPPFLAGS"

print_status "Building Aegisum Core (this may take a while)..."
make -j$(sysctl -n hw.ncpu)

print_status "Build completed successfully!"

# Check if binaries were created
if [[ -f "src/aegisumd" ]]; then
    print_status "✅ aegisumd (daemon) built successfully"
else
    print_error "❌ aegisumd failed to build"
fi

if [[ -f "src/aegisum-cli" ]]; then
    print_status "✅ aegisum-cli built successfully"
else
    print_error "❌ aegisum-cli failed to build"
fi

if [[ -f "src/qt/aegisum-qt" ]]; then
    print_status "✅ aegisum-qt (GUI) built successfully"
else
    print_warning "⚠️  aegisum-qt (GUI) failed to build"
fi

if [[ -f "src/aegisum-tx" ]]; then
    print_status "✅ aegisum-tx built successfully"
else
    print_error "❌ aegisum-tx failed to build"
fi

if [[ -f "src/aegisum-wallet" ]]; then
    print_status "✅ aegisum-wallet built successfully"
else
    print_error "❌ aegisum-wallet failed to build"
fi

print_status "🎉 Aegisum Core macOS build process completed!"
print_status "Binaries are located in the 'src' directory"

# Create app bundle if GUI was built
if [[ -f "src/qt/aegisum-qt" ]]; then
    print_status "Creating macOS app bundle..."
    ./contrib/macdeploy/macdeployqtplus Aegisum-Qt.app -add-qt-tr da,de,es,hu,ru,uk,zh_CN,zh_TW -dmg -fancy ./contrib/macdeploy/fancy.plist -verbose 2
    
    if [[ -f "Aegisum-Core.dmg" ]]; then
        print_status "✅ DMG file created: Aegisum-Core.dmg"
    else
        print_warning "⚠️  DMG creation failed, but binaries are available"
    fi
fi

echo ""
print_status "=== BUILD SUMMARY ==="
print_status "Core daemon: src/aegisumd"
print_status "CLI tool: src/aegisum-cli"
print_status "Transaction tool: src/aegisum-tx"
print_status "Wallet tool: src/aegisum-wallet"
if [[ -f "src/qt/aegisum-qt" ]]; then
    print_status "GUI wallet: src/qt/aegisum-qt"
fi
if [[ -f "Aegisum-Core.dmg" ]]; then
    print_status "DMG installer: Aegisum-Core.dmg"
fi
echo ""
print_status "🚀 Your Aegisum Core macOS wallet is ready!"