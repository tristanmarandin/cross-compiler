#!/bin/bash

# Cross-compilation script for ARM64 using qmake
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
            echo "Cross-compilation script for ARM64 using qmake"
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

# Cross-compiler settings
CC=aarch64-linux-gnu-gcc
CXX=aarch64-linux-gnu-g++

echo -e "${GREEN}=== ARM64 Cross-Compilation Build Script (using qmake) ===${NC}"
echo ""

# Use Qt qmake from /opt/qt-arm64
QT_QMAKE="/opt/qt-arm64/bin/qmake"
if [ ! -f "$QT_QMAKE" ]; then
    echo -e "${RED}Error: Qt qmake not found at $QT_QMAKE${NC}"
    echo "Qt Core must be cross-compiled first in the Dockerfile"
    exit 1
fi
echo -e "${GREEN}Using Qt qmake: $QT_QMAKE${NC}"

# Check if cross-compiler is available
if ! command -v $CXX &> /dev/null; then
    echo -e "${RED}Error: $CXX not found!${NC}"
    echo "Please install the cross-compiler:"
    echo "  sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"
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

# Get the absolute path to the project root (parent of build directory)
PROJECT_ROOT=$(cd .. && pwd)
MKSPEC_PATH="$PROJECT_ROOT/mkspecs/linux-aarch64-g++"

# Build the project using qmake
echo -e "${GREEN}Building project for ARM64 using qmake...${NC}"
if [ "$VERBOSE" = true ]; then
    echo "Cross-compiler: $CXX"
    echo "Qmake spec: linux-aarch64-g++"
    echo "Mkspec path: $MKSPEC_PATH"
    echo ""
    # Set QMAKESPEC to point to our custom mkspec directory
    export QMAKESPEC="$MKSPEC_PATH"
    export PATH="/opt/qt-arm64/bin:$PATH"
    $QT_QMAKE .. \
        "CONFIG+=qt" \
        "CONFIG+=static" \
        "QT+=core" \
        "QMAKE_CC=$CC" \
        "QMAKE_CXX=$CXX" \
        "QMAKE_LINK=$CXX" \
        "QMAKE_CFLAGS=-march=armv8-a" \
        "QMAKE_CXXFLAGS=-march=armv8-a" \
        "QMAKE_LFLAGS=-march=armv8-a"
    make VERBOSE=1
else
    
    export PATH="/opt/qt-arm64/bin:$PATH"
    $QT_QMAKE .. \
    "CONFIG+=static" \
    "QT+=core" \
    "QMAKE_CC=$CC" \
    "QMAKE_CXX=$CXX" \
    "QMAKE_LINK=$CXX" \
    "QMAKE_CFLAGS=-march=armv8-a" \
    "QMAKE_CXXFLAGS=-march=armv8-a" \
    "QMAKE_LFLAGS=-march=armv8-a"
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
        elif command -v file &> /dev/null; then
            FILE_INFO=$(file ./HelloWorld)
            echo -e "File info: ${GREEN}${FILE_INFO}${NC}"
            if echo "$FILE_INFO" | grep -q "aarch64\|ARM"; then
                echo -e "${GREEN}✓ Binary appears to be compiled for ARM64${NC}"
            else
                echo -e "${YELLOW}⚠ Could not verify architecture with file command${NC}"
            fi
        else
            echo -e "${YELLOW}readelf and file not available, skipping verification${NC}"
        fi
    else
        echo -e "${RED}Error: HelloWorld executable not found!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=== Build completed successfully! ===${NC}"
echo "Binary location: $(pwd)/HelloWorld"
