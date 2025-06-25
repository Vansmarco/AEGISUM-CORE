#!/bin/bash
# Aegisum Core - Complete macOS Wallet Builder
# This script builds and packages the complete Aegisum wallet for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Header
print_header() {
    echo -e "${PURPLE}"
    echo "    ___    _____ ____ _____ _____ __  __ __  __ "
    echo "   /   |  / ____/  _// ___// ___// / / //  |/  /"
    echo "  / /| | / __/  / /  \__ \ \__ \/ / / // /|_/ / "
    echo " / ___ |/ /___ / /  ___/ /___/ / /_/ // /  / /  "
    echo "/_/  |_/_____/___/ /____//____/ \____//_/  /_/   "
    echo ""
    echo "           macOS Wallet Builder v1.0"
    echo -e "${NC}"
}

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

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Print header
clear
print_header

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    echo ""
    echo "To build for macOS on other platforms, use the Gitian build system:"
    echo "  contrib/gitian-descriptors/gitian-osx.yml"
    exit 1
fi

# Parse command line arguments
BUILD_ONLY=false
DEPLOY_ONLY=false
CLEAN_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --deploy-only)
            DEPLOY_ONLY=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --help|-h)
            echo "Aegisum Core macOS Wallet Builder"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --build-only    Only build, don't create deployment package"
            echo "  --deploy-only   Only create deployment package (assumes build exists)"
            echo "  --clean         Clean build (remove all previous build artifacts)"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Full build and deployment"
            echo "  $0 --clean           # Clean build and deployment"
            echo "  $0 --build-only      # Build only, no DMG creation"
            echo "  $0 --deploy-only     # Create DMG from existing build"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Step 1: Environment Check
print_step "1/5 - Environment Check"
print_status "Checking build environment..."

# Check for required tools
MISSING_TOOLS=()

if ! command -v xcode-select &> /dev/null; then
    MISSING_TOOLS+=("xcode-select")
fi

if ! command -v brew &> /dev/null; then
    MISSING_TOOLS+=("homebrew")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    print_error "Missing required tools: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Please install:"
    for tool in "${MISSING_TOOLS[@]}"; do
        case $tool in
            "xcode-select")
                echo "  - Xcode Command Line Tools: xcode-select --install"
                ;;
            "homebrew")
                echo "  - Homebrew: https://brew.sh"
                ;;
        esac
    done
    exit 1
fi

print_success "Environment check passed"

# Step 2: Clean Build (if requested)
if [ "$CLEAN_BUILD" = true ]; then
    print_step "2/5 - Clean Build"
    print_status "Cleaning previous build artifacts..."
    
    make clean 2>/dev/null || true
    rm -rf Aegisum-Qt.app
    rm -rf dist/
    rm -f *.dmg
    rm -rf depends/built/
    rm -rf depends/work/
    
    print_success "Clean completed"
else
    print_step "2/5 - Clean Build (Skipped)"
fi

# Step 3: Build
if [ "$DEPLOY_ONLY" != true ]; then
    print_step "3/5 - Build Process"
    
    if [ -f "build-macos.sh" ]; then
        print_status "Running automated build script..."
        ./build-macos.sh
    else
        print_status "Running manual build process..."
        
        # Install dependencies
        print_status "Installing dependencies..."
        brew install automake libtool boost miniupnpc pkg-config python qt libevent qrencode fmt librsvg berkeley-db4 sqlite
        
        # Build
        print_status "Configuring build..."
        ./autogen.sh
        ./configure --enable-reduce-exports --disable-bench --with-gui=qt5
        
        print_status "Compiling (this may take a while)..."
        make -j$(sysctl -n hw.ncpu)
        
        print_status "Creating app bundle..."
        make appbundle
    fi
    
    print_success "Build completed"
else
    print_step "3/5 - Build Process (Skipped)"
fi

# Step 4: Create Icon
print_step "4/5 - Branding"
if [ -f "create-macos-icon.sh" ]; then
    print_status "Creating Aegisum-branded macOS icon..."
    ./create-macos-icon.sh
    print_success "Icon created"
else
    print_warning "Icon creation script not found, using default icon"
fi

# Step 5: Deployment
if [ "$BUILD_ONLY" != true ]; then
    print_step "5/5 - Deployment"
    
    if [ -f "deploy-macos.sh" ]; then
        print_status "Running deployment script..."
        ./deploy-macos.sh
    else
        print_status "Running basic deployment..."
        make deploy
    fi
    
    print_success "Deployment completed"
else
    print_step "5/5 - Deployment (Skipped)"
fi

# Final Summary
echo ""
echo -e "${PURPLE}================================${NC}"
echo -e "${PURPLE}    BUILD SUMMARY${NC}"
echo -e "${PURPLE}================================${NC}"

if [ "$BUILD_ONLY" != true ]; then
    if [ -f "Aegisum-Core-macOS.dmg" ]; then
        SIZE=$(du -h "Aegisum-Core-macOS.dmg" | cut -f1)
        print_success "DMG Created: Aegisum-Core-macOS.dmg ($SIZE)"
    elif [ -f "Aegisum-Qt.dmg" ]; then
        SIZE=$(du -h "Aegisum-Qt.dmg" | cut -f1)
        print_success "DMG Created: Aegisum-Qt.dmg ($SIZE)"
    fi
fi

if [ -d "Aegisum-Qt.app" ]; then
    print_success "App Bundle: Aegisum-Qt.app"
fi

echo ""
echo -e "${CYAN}Installation Instructions:${NC}"
echo "1. Open the DMG file"
echo "2. Drag Aegisum-Qt.app to Applications folder"
echo "3. Launch from Applications or Launchpad"
echo ""

echo -e "${CYAN}What's Included:${NC}"
echo "• Aegisum-Qt (GUI Wallet)"
echo "• aegisumd (Blockchain Daemon)"
echo "• aegisum-cli (Command Line Interface)"
echo "• aegisum-tx (Transaction Utility)"
echo "• aegisum-wallet (Wallet Management)"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo "• Test the wallet on your Mac"
echo "• Create backups of important wallets"
echo "• Share with the Aegisum community"
echo ""

print_success "macOS wallet build completed successfully!"
echo -e "${PURPLE}Thank you for supporting Aegisum! 🚀${NC}"