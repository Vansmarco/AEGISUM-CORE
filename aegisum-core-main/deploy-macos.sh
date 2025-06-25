#!/bin/bash
# Aegisum Core macOS Deployment Script
# This script creates a complete, branded macOS wallet distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}[AEGISUM]${NC} $1"
}

# Print header
print_header "Aegisum Core macOS Deployment"
print_header "=============================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

# Check if build exists
if [ ! -f "src/qt/aegisum-qt" ] && [ ! -f "src/qt/bitcoin-qt" ]; then
    print_error "Aegisum-Qt binary not found. Please run build first."
    print_status "Run: ./build-macos.sh"
    exit 1
fi

# Create branded icon if needed
print_status "Ensuring proper Aegisum branding..."
if [ -f "create-macos-icon.sh" ]; then
    ./create-macos-icon.sh
fi

# Clean previous deployment
print_status "Cleaning previous deployment..."
rm -rf Aegisum-Qt.app
rm -rf dist/
rm -f *.dmg

# Create the app bundle structure
print_status "Creating macOS app bundle..."
APP_NAME="Aegisum-Qt.app"
CONTENTS_DIR="$APP_NAME/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$FRAMEWORKS_DIR"

# Copy the main executable
print_status "Installing main executable..."
if [ -f "src/qt/aegisum-qt" ]; then
    cp "src/qt/aegisum-qt" "$MACOS_DIR/Aegisum-Qt"
elif [ -f "src/qt/bitcoin-qt" ]; then
    cp "src/qt/bitcoin-qt" "$MACOS_DIR/Aegisum-Qt"
fi

# Make executable
chmod +x "$MACOS_DIR/Aegisum-Qt"

# Copy daemon and CLI tools
print_status "Installing command-line tools..."
if [ -f "src/aegisumd" ]; then
    cp "src/aegisumd" "$MACOS_DIR/"
elif [ -f "src/bitcoind" ]; then
    cp "src/bitcoind" "$MACOS_DIR/aegisumd"
fi

if [ -f "src/aegisum-cli" ]; then
    cp "src/aegisum-cli" "$MACOS_DIR/"
elif [ -f "src/bitcoin-cli" ]; then
    cp "src/bitcoin-cli" "$MACOS_DIR/aegisum-cli"
fi

if [ -f "src/aegisum-tx" ]; then
    cp "src/aegisum-tx" "$MACOS_DIR/"
elif [ -f "src/bitcoin-tx" ]; then
    cp "src/bitcoin-tx" "$MACOS_DIR/aegisum-tx"
fi

if [ -f "src/aegisum-wallet" ]; then
    cp "src/aegisum-wallet" "$MACOS_DIR/"
elif [ -f "src/bitcoin-wallet" ]; then
    cp "src/bitcoin-wallet" "$MACOS_DIR/aegisum-wallet"
fi

# Copy icon
print_status "Installing application icon..."
cp "src/qt/res/icons/bitcoin.icns" "$RESOURCES_DIR/"

# Create Info.plist
print_status "Creating Info.plist..."
if [ -f "share/qt/Info.plist" ]; then
    cp "share/qt/Info.plist" "$CONTENTS_DIR/"
else
    # Create a basic Info.plist if the generated one doesn't exist
    cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Aegisum-Qt</string>
    <key>CFBundleIdentifier</key>
    <string>org.aegisum.Aegisum-Qt</string>
    <key>CFBundleName</key>
    <string>Aegisum-Qt</string>
    <key>CFBundleDisplayName</key>
    <string>Aegisum Core</string>
    <key>CFBundleVersion</key>
    <string>0.21.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.21.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>bitcoin.icns</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.finance</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>org.aegisum.AegisumPayment</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>aegisum</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF
fi

# Create PkgInfo
echo "APPLAEGS" > "$CONTENTS_DIR/PkgInfo"

# Deploy Qt frameworks and fix dependencies
print_status "Deploying Qt frameworks..."
if command -v macdeployqt &> /dev/null; then
    macdeployqt "$APP_NAME" -verbose=2
elif [ -f "contrib/macdeploy/macdeployqtplus" ]; then
    python3 contrib/macdeploy/macdeployqtplus "$APP_NAME" -verbose 2
else
    print_warning "macdeployqt not found. You may need to install Qt dependencies manually."
fi

# Sign the app bundle (ad-hoc signature)
print_status "Signing application bundle..."
codesign --force --deep --sign - "$APP_NAME" || print_warning "Code signing failed (this is normal for development builds)"

# Create DMG
print_status "Creating disk image..."
DMG_NAME="Aegisum-Core-macOS.dmg"
TEMP_DMG="temp.dmg"

# Create temporary directory for DMG contents
DMG_DIR=$(mktemp -d)
cp -R "$APP_NAME" "$DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create background image if we have the tools
if command -v sips &> /dev/null && [ -f "contrib/macdeploy/background.svg" ]; then
    print_status "Creating DMG background..."
    mkdir -p "$DMG_DIR/.background"
    # Convert SVG to PNG for background
    if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 660 -h 400 contrib/macdeploy/background.svg -o "$DMG_DIR/.background/background.png"
    fi
fi

# Calculate size needed for DMG
SIZE=$(du -sm "$DMG_DIR" | cut -f1)
SIZE=$((SIZE + 50)) # Add some padding

# Create DMG
print_status "Building disk image..."
hdiutil create -srcfolder "$DMG_DIR" -volname "Aegisum Core" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${SIZE}m "$TEMP_DMG"

# Mount DMG to customize it
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | egrep '^/dev/' | sed 1q | awk '{print $1}')
MOUNT_POINT="/Volumes/Aegisum Core"

# Set DMG window properties
if [ -d "$MOUNT_POINT" ]; then
    print_status "Customizing DMG appearance..."
    
    # Create .DS_Store for custom view
    cat > /tmp/dmg_setup.applescript << EOF
tell application "Finder"
    tell disk "Aegisum Core"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 1060, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set background picture of viewOptions to file ".background:background.png"
        set position of item "Aegisum-Qt.app" of container window to {180, 200}
        set position of item "Applications" of container window to {480, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF
    
    osascript /tmp/dmg_setup.applescript || print_warning "DMG customization failed"
    rm /tmp/dmg_setup.applescript
fi

# Unmount and compress DMG
print_status "Finalizing disk image..."
hdiutil detach "$DEVICE"
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"
rm "$TEMP_DMG"

# Clean up
rm -rf "$DMG_DIR"

# Verify the build
print_status "Verifying deployment..."
if [ -f "$DMG_NAME" ]; then
    SIZE=$(du -h "$DMG_NAME" | cut -f1)
    print_success "macOS deployment completed successfully!"
    print_success "Created: $DMG_NAME ($SIZE)"
    
    if [ -d "$APP_NAME" ]; then
        print_success "App bundle: $APP_NAME"
        
        # Test app launch
        print_status "Testing application..."
        timeout 5s "./$APP_NAME/Contents/MacOS/Aegisum-Qt" --help > /dev/null 2>&1 && print_success "Application launches successfully" || print_warning "Application test inconclusive"
    fi
    
    print_header ""
    print_header "Installation Instructions:"
    print_header "1. Open $DMG_NAME"
    print_header "2. Drag Aegisum-Qt.app to Applications folder"
    print_header "3. Launch from Applications or Launchpad"
    print_header ""
    print_header "The wallet includes:"
    print_header "- Aegisum-Qt (GUI wallet)"
    print_header "- aegisumd (daemon)"
    print_header "- aegisum-cli (command line interface)"
    print_header "- aegisum-tx (transaction utility)"
    print_header "- aegisum-wallet (wallet utility)"
    
else
    print_error "Failed to create DMG"
    exit 1
fi