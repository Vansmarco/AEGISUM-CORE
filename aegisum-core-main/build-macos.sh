#!/bin/bash
# Aegisum Core macOS Build Script
# This script builds the complete Aegisum Core wallet for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

# Check for required tools
print_status "Checking for required tools..."

# Check for Xcode command line tools
if ! xcode-select -p &> /dev/null; then
    print_error "Xcode command line tools not found. Please run: xcode-select --install"
    exit 1
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found. Please install from https://brew.sh"
    exit 1
fi

print_success "Required tools found"

# Install dependencies
print_status "Installing/updating dependencies..."
brew install automake libtool boost miniupnpc pkg-config python qt libevent qrencode fmt librsvg berkeley-db4 sqlite

# Set up build environment
print_status "Setting up build environment..."
export LDFLAGS="-L$(brew --prefix)/lib"
export CPPFLAGS="-I$(brew --prefix)/include"
export PKG_CONFIG_PATH="$(brew --prefix)/lib/pkgconfig"

# Clean previous builds
print_status "Cleaning previous builds..."
make clean || true
rm -rf Aegisum-Qt.app || true
rm -rf *.dmg || true

# Generate build files
print_status "Generating build configuration..."
./autogen.sh

# Configure build
print_status "Configuring build for macOS..."
./configure \
    --enable-reduce-exports \
    --disable-bench \
    --disable-tests \
    --with-gui=qt5 \
    --enable-wallet \
    --with-sqlite=yes \
    --with-incompatible-bdb \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# Build the application
print_status "Building Aegisum Core..."
make -j$(sysctl -n hw.ncpu)

# Create the app bundle
print_status "Creating macOS app bundle..."
make appbundle

# Deploy Qt and create DMG
print_status "Deploying application and creating DMG..."
make deploy

# Verify the build
print_status "Verifying build..."
if [ -f "Aegisum-Qt.dmg" ]; then
    print_success "macOS DMG created successfully: Aegisum-Qt.dmg"
    
    # Get file size
    SIZE=$(du -h "Aegisum-Qt.dmg" | cut -f1)
    print_status "DMG size: $SIZE"
    
    # Verify app bundle
    if [ -d "Aegisum-Qt.app" ]; then
        print_success "App bundle created: Aegisum-Qt.app"
        
        # Check if the binary is properly signed (will show ad-hoc signature)
        codesign -dv Aegisum-Qt.app 2>&1 | grep -q "adhoc" && print_status "App bundle is ad-hoc signed"
        
        # Test if the app can launch (just check if it starts)
        print_status "Testing app launch..."
        timeout 5s ./Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt --help > /dev/null 2>&1 && print_success "App launches successfully" || print_warning "App launch test inconclusive"
    fi
else
    print_error "Failed to create DMG"
    exit 1
fi

print_success "macOS build completed successfully!"
print_status "Files created:"
print_status "  - Aegisum-Qt.app (Application bundle)"
print_status "  - Aegisum-Qt.dmg (Disk image for distribution)"
print_status ""
print_status "To install: Open Aegisum-Qt.dmg and drag Aegisum-Qt.app to Applications folder"