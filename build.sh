#!/bin/bash

# Cross-compilation script for ARM64 using Qmake/Qt
# Usage: ./build.sh [options]
# Options:
#   --clean      Clean build directory before building
#   --verbose    Enable verbose output
#   --verify     Verify the compiled binary architecture
#   --help       Show this help message

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default options
CLEAN=false
VERBOSE=false
VERIFY=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --no-verify)
            VERIFY=false
            shift
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        --help)
            echo "Cross-compilation script for ARM64"
            echo ""
            echo "Usage: ./build.sh [options]"
            echo ""
            echo "Options:"
            echo "  --clean      Clean build directory before building"
            echo "  --verbose    Enable verbose output"
            echo "  --verify     Verify the compiled binary architecture (default)"
            echo "  --no-verify  Skip architecture verification"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Qmake configuration for ARM64 cross-compilation
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++

# Qmake arguments for cross-compilation
QMAKE_ARGS=(
    "QMAKE_CC=$CC"
    "QMAKE_CXX=$CXX"
    "QMAKE_LINK=$CXX"
    "QMAKE_LINK_SHLIB=$CXX"
    "QMAKE_AR=aarch64-linux-gnu-ar"
    "QMAKE_STRIP=aarch64-linux-gnu-strip"
    "QMAKE_OBJCOPY=aarch64-linux-gnu-objcopy"
    "QMAKE_CFLAGS=-march=armv8-a"
    "QMAKE_CXXFLAGS=-march=armv8-a"
    "QMAKE_LFLAGS=-march=armv8-a"
)

# Verbose flag
if [ "$VERBOSE" = true ]; then
    QMAKE_ARGS+=("CONFIG+=debug")
fi

echo -e "${GREEN}=== ARM64 Cross-Compilation Build Script ===${NC}"
echo ""

# Check if cross-compiler is available
if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo -e "${RED}Error: aarch64-linux-gnu-gcc not found!${NC}"
    echo "Please install the cross-compiler:"
    echo "  sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"
    exit 1
fi

# Check if qmake is available
if ! command -v qmake &> /dev/null; then
    echo -e "${RED}Error: qmake not found!${NC}"
    echo "Please install Qt development tools:"
    echo "  sudo apt-get install qtbase5-dev qmake"
    exit 1
fi

# Clean build directory if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf build
fi

# Create build directory
mkdir -p build
cd build

# Configure Qmake
echo -e "${GREEN}Configuring Qmake for ARM64...${NC}"
if [ "$VERBOSE" = true ]; then
    echo "Qmake arguments: ${QMAKE_ARGS[@]}"
fi
qmake .. "${QMAKE_ARGS[@]}"

# Build
echo -e "${GREEN}Building project...${NC}"
if [ "$VERBOSE" = true ]; then
    make VERBOSE=1
else
    make
fi

# Verify architecture if requested
if [ "$VERIFY" = true ]; then
    echo ""
    echo -e "${GREEN}Verifying binary architecture...${NC}"
    if [ -f "./HelloWorld" ]; then
        if command -v readelf &> /dev/null; then
            ARCH=$(readelf -h ./HelloWorld | grep "Machine:" | awk '{print $2}')
            echo -e "Architecture: ${GREEN}${ARCH}${NC}"
            if [ "$ARCH" = "AArch64" ]; then
                echo -e "${GREEN}✓ Binary is correctly compiled for ARM64${NC}"
            else
                echo -e "${RED}✗ Warning: Binary is not compiled for ARM64!${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}readelf not available, skipping verification${NC}"
        fi
    else
        echo -e "${RED}Error: HelloWorld executable not found!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=== Build completed successfully! ===${NC}"
echo "Binary location: $(pwd)/HelloWorld"
