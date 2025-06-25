#!/bin/bash
# Script to create proper macOS icon from Aegisum branding

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if we have the source image
if [ ! -f "src/qt/res/icons/aegisum_splash.png" ]; then
    echo "Error: aegisum_splash.png not found"
    exit 1
fi

# Create temporary directory for icon generation
TEMP_DIR=$(mktemp -d)
SOURCE_IMAGE="src/qt/res/icons/aegisum_splash.png"
ICONSET_DIR="$TEMP_DIR/aegisum.iconset"

print_status "Creating macOS icon from Aegisum branding..."

# Create iconset directory
mkdir -p "$ICONSET_DIR"

# Generate all required icon sizes for macOS
# Standard sizes for .icns files
declare -a sizes=("16" "32" "64" "128" "256" "512" "1024")
declare -a retina_sizes=("32" "64" "128" "256" "512" "1024")

print_status "Generating icon sizes..."

# Generate standard resolution icons
for size in "${sizes[@]}"; do
    if command -v sips &> /dev/null; then
        sips -z $size $size "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_${size}x${size}.png" > /dev/null 2>&1
    elif command -v convert &> /dev/null; then
        convert "$SOURCE_IMAGE" -resize ${size}x${size} "$ICONSET_DIR/icon_${size}x${size}.png"
    else
        echo "Error: Neither sips nor ImageMagick convert found. Please install ImageMagick: brew install imagemagick"
        exit 1
    fi
done

# Generate retina (@2x) icons
for size in "${retina_sizes[@]}"; do
    retina_size=$((size * 2))
    if command -v sips &> /dev/null; then
        sips -z $retina_size $retina_size "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    elif command -v convert &> /dev/null; then
        convert "$SOURCE_IMAGE" -resize ${retina_size}x${retina_size} "$ICONSET_DIR/icon_${size}x${size}@2x.png"
    fi
done

# Create the .icns file
print_status "Creating .icns file..."
if command -v iconutil &> /dev/null; then
    iconutil -c icns "$ICONSET_DIR" -o "$TEMP_DIR/aegisum.icns"
    
    # Replace the old bitcoin.icns with our new Aegisum icon
    cp "$TEMP_DIR/aegisum.icns" "src/qt/res/icons/bitcoin.icns"
    
    print_success "Created Aegisum-branded macOS icon: src/qt/res/icons/bitcoin.icns"
else
    echo "Error: iconutil not found. This script must be run on macOS."
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"

print_success "macOS icon creation completed!"