#!/bin/bash

# Cross-compilation script for ARM64
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

# CMake configuration for ARM64 cross-compilation
CMAKE_ARGS=(
    -DCMAKE_SYSTEM_NAME=Linux
    -DCMAKE_SYSTEM_PROCESSOR=aarch64
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc
    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
)

# Add CMAKE_FIND_ROOT_PATH if dependencies are installed
if [ -d "/usr/aarch64-linux-gnu" ]; then
    CMAKE_ARGS+=(
        -DCMAKE_FIND_ROOT_PATH=/usr/aarch64-linux-gnu
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
    )
fi

# Verbose flag
if [ "$VERBOSE" = true ]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
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

# Clean build directory if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf build
fi

# Create build directory
mkdir -p build
cd build

# Configure CMake
echo -e "${GREEN}Configuring CMake for ARM64...${NC}"
if [ "$VERBOSE" = true ]; then
    echo "CMake arguments: ${CMAKE_ARGS[@]}"
fi
cmake .. "${CMAKE_ARGS[@]}"

# Build
echo -e "${GREEN}Building project...${NC}"
if [ "$VERBOSE" = true ]; then
    cmake --build . --verbose
else
    cmake --build .
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
