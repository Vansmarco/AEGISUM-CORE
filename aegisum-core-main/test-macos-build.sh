#!/bin/bash
# Aegisum Core macOS Build Test Script
# This script tests the macOS build to ensure it works correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Testing: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        print_success "$test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "$test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "Aegisum Core macOS Build Test Suite"
echo "===================================="
echo ""

# Test 1: Check if we're on macOS
run_test "macOS Platform Check" '[[ "$OSTYPE" == "darwin"* ]]'

# Test 2: Check for app bundle
run_test "App Bundle Exists" '[ -d "Aegisum-Qt.app" ]'

# Test 3: Check main executable
run_test "Main Executable Exists" '[ -f "Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt" ]'

# Test 4: Check executable permissions
run_test "Executable Permissions" '[ -x "Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt" ]'

# Test 5: Check Info.plist
run_test "Info.plist Exists" '[ -f "Aegisum-Qt.app/Contents/Info.plist" ]'

# Test 6: Check icon file
run_test "Icon File Exists" '[ -f "Aegisum-Qt.app/Contents/Resources/bitcoin.icns" ]'

# Test 7: Check PkgInfo
run_test "PkgInfo Exists" '[ -f "Aegisum-Qt.app/Contents/PkgInfo" ]'

# Test 8: Test app launch (help command)
if [ -f "Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt" ]; then
    run_test "App Launch Test" 'timeout 10s ./Aegisum-Qt.app/Contents/MacOS/Aegisum-Qt --help'
fi

# Test 9: Check for command line tools
run_test "Daemon Tool Exists" '[ -f "Aegisum-Qt.app/Contents/MacOS/aegisumd" ] || [ -f "src/aegisumd" ] || [ -f "src/bitcoind" ]'

run_test "CLI Tool Exists" '[ -f "Aegisum-Qt.app/Contents/MacOS/aegisum-cli" ] || [ -f "src/aegisum-cli" ] || [ -f "src/bitcoin-cli" ]'

# Test 10: Check DMG file (if exists)
if [ -f "Aegisum-Core-macOS.dmg" ] || [ -f "Aegisum-Qt.dmg" ]; then
    run_test "DMG File Exists" '[ -f "Aegisum-Core-macOS.dmg" ] || [ -f "Aegisum-Qt.dmg" ]'
fi

# Test 11: Check code signature (should be ad-hoc)
if command -v codesign &> /dev/null; then
    run_test "Code Signature Check" 'codesign -dv Aegisum-Qt.app 2>&1 | grep -q "adhoc\|Authority=\|Signature="'
fi

# Test 12: Check bundle identifier
run_test "Bundle Identifier Check" 'grep -q "org.aegisum" Aegisum-Qt.app/Contents/Info.plist'

# Test 13: Check Qt frameworks (if deployed)
if [ -d "Aegisum-Qt.app/Contents/Frameworks" ]; then
    run_test "Qt Frameworks Deployed" '[ -d "Aegisum-Qt.app/Contents/Frameworks" ] && [ "$(ls -A Aegisum-Qt.app/Contents/Frameworks)" ]'
fi

# Test 14: Verify app structure
run_test "App Structure Valid" '[ -d "Aegisum-Qt.app/Contents/MacOS" ] && [ -d "Aegisum-Qt.app/Contents/Resources" ]'

# Test 15: Check for proper branding
run_test "Aegisum Branding Check" 'grep -q -i "aegisum" Aegisum-Qt.app/Contents/Info.plist'

echo ""
echo "Test Results Summary"
echo "===================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    print_success "All tests passed! The macOS build appears to be working correctly."
    echo ""
    echo "Next steps:"
    echo "1. Test the wallet functionality manually"
    echo "2. Verify network connectivity"
    echo "3. Test wallet creation and backup"
    echo "4. Share with the community for testing"
    exit 0
else
    echo ""
    print_error "Some tests failed. Please check the build process."
    echo ""
    echo "Common issues:"
    echo "- Run the build script first: ./make-macos-wallet.sh"
    echo "- Ensure all dependencies are installed"
    echo "- Check for build errors in the output"
    exit 1
fi