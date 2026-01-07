#!/bin/bash

# Cross-compilation script for ARM64 using Qmake/Qt
# Supports complex Qt projects with automatic detection
# Usage: ./build.sh [options]
# Options:
#   --clean      Clean build directory before building
#   --verbose    Enable verbose output
#   --verify     Verify the compiled binary architecture
#   --pro-file   Specify .pro file path (auto-detected if not provided)
#   --help       Show this help message

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
CLEAN=false
VERBOSE=false
VERIFY=true
PRO_FILE=""
TARGET_NAME=""

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
        --pro-file)
            PRO_FILE="$2"
            shift 2
            ;;
        --help)
            echo "Cross-compilation script for ARM64 using Qmake/Qt"
            echo ""
            echo "Usage: ./build.sh [options]"
            echo ""
            echo "Options:"
            echo "  --clean        Clean build directory before building"
            echo "  --verbose      Enable verbose output"
            echo "  --verify       Verify the compiled binary architecture (default)"
            echo "  --no-verify    Skip architecture verification"
            echo "  --pro-file     Specify .pro file path (auto-detected if not provided)"
            echo "  --help         Show this help message"
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
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/lib/pkgconfig

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

# Auto-detect .pro file if not provided
if [ -z "$PRO_FILE" ]; then
    echo -e "${BLUE}Auto-detecting .pro file...${NC}"
    PRO_FILE=$(find . -maxdepth 2 -name "*.pro" -type f | grep -v build | head -1)
    if [ -z "$PRO_FILE" ]; then
        echo -e "${RED}Error: No .pro file found!${NC}"
        echo "Please create a .pro file or specify one with --pro-file option"
        exit 1
    fi
    echo -e "${GREEN}Found: ${PRO_FILE}${NC}"
else
    if [ ! -f "$PRO_FILE" ]; then
        echo -e "${RED}Error: .pro file not found: $PRO_FILE${NC}"
        exit 1
    fi
fi

# Extract target name from .pro file
TARGET_NAME=$(grep -E "^TARGET\s*=" "$PRO_FILE" | sed 's/TARGET\s*=\s*//' | tr -d ' ' | head -1)
if [ -z "$TARGET_NAME" ]; then
    # Try to get from filename
    TARGET_NAME=$(basename "$PRO_FILE" .pro)
fi

# Detect Qt modules required
echo -e "${BLUE}Analyzing Qt modules...${NC}"
QT_MODULES=$(grep -E "^QT\s*\+=" "$PRO_FILE" | sed 's/QT\s*+=\s*//' | tr '\n' ' ')
if [ -n "$QT_MODULES" ]; then
    echo -e "${GREEN}Required Qt modules: ${QT_MODULES}${NC}"
fi

# Qmake arguments for cross-compilation
QMAKE_ARGS=(
    "QMAKE_CC=$CC"
    "QMAKE_CXX=$CXX"
    "QMAKE_LINK=$CXX"
    "QMAKE_LINK_SHLIB=$CXX"
    "QMAKE_AR=aarch64-linux-gnu-ar"
    "QMAKE_STRIP=aarch64-linux-gnu-strip"
    "QMAKE_OBJCOPY=aarch64-linux-gnu-objcopy"
    "QMAKE_NM=aarch64-linux-gnu-nm"
    "QMAKE_CFLAGS=-march=armv8-a"
    "QMAKE_CXXFLAGS=-march=armv8-a"
    "QMAKE_LFLAGS=-march=armv8-a"
    # Qt tools paths
    "QMAKE_RCC=/usr/bin/rcc"
    "QMAKE_MOC=/usr/bin/moc"
    "QMAKE_UIC=/usr/bin/uic"
    "QMAKE_QDBUSCPP2XML=/usr/bin/qdbuscpp2xml"
    "QMAKE_QDBUSXML2CPP=/usr/bin/qdbusxml2cpp"
    # Library search paths
    "QMAKE_LIBDIR_FLAGS=-L/usr/lib/aarch64-linux-gnu"
    "QMAKE_INCDIR=/usr/include/aarch64-linux-gnu"
    # Sysroot configuration
    "QMAKE_SYSROOT=/usr/aarch64-linux-gnu"
)

# Verbose flag
if [ "$VERBOSE" = true ]; then
    QMAKE_ARGS+=("CONFIG+=debug" "CONFIG+=verbose")
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
echo ""
echo -e "${GREEN}Configuring Qmake for ARM64...${NC}"
if [ "$VERBOSE" = true ]; then
    echo "Qmake arguments:"
    for arg in "${QMAKE_ARGS[@]}"; do
        echo "  $arg"
    done
fi

# Determine project root (parent of .pro file or current dir)
PRO_DIR=$(dirname "$PRO_FILE")
if [ "$PRO_DIR" = "." ]; then
    PRO_DIR=".."
else
    PRO_DIR="../$PRO_DIR"
fi

qmake "$PRO_DIR/$PRO_FILE" "${QMAKE_ARGS[@]}" || {
    echo -e "${RED}Qmake configuration failed!${NC}"
    exit 1
}

# Build
echo ""
echo -e "${GREEN}Building project...${NC}"
if [ "$VERBOSE" = true ]; then
    make VERBOSE=1 -j$(nproc)
else
    make -j$(nproc)
fi

# Verify architecture if requested
if [ "$VERIFY" = true ]; then
    echo ""
    echo -e "${GREEN}Verifying binary architecture...${NC}"
    
    # Try to find the binary
    BINARY=""
    if [ -f "./$TARGET_NAME" ]; then
        BINARY="./$TARGET_NAME"
    elif [ -f "./$TARGET_NAME/$TARGET_NAME" ]; then
        BINARY="./$TARGET_NAME/$TARGET_NAME"
    else
        # Search for executable matching target name, excluding CMake artifacts
        BINARY=$(find . -maxdepth 2 -type f -executable -name "$TARGET_NAME" -not -path "*/CMakeFiles/*" -not -path "*/\.*" | head -1)
        if [ -z "$BINARY" ]; then
            # Fallback: search for any executable, excluding CMake and hidden files
            BINARY=$(find . -maxdepth 2 -type f -executable -not -name "*.o" -not -name "*.so" -not -path "*/CMakeFiles/*" -not -path "*/\.*" | head -1)
        fi
    fi
    
    if [ -n "$BINARY" ] && [ -f "$BINARY" ]; then
        if command -v readelf &> /dev/null; then
            ARCH=$(readelf -h "$BINARY" 2>/dev/null | grep "Machine:" | awk '{print $2}')
            if [ "$ARCH" = "AArch64" ]; then
                echo -e "Architecture: ${GREEN}${ARCH}${NC}"
                echo -e "${GREEN}✓ Binary is correctly compiled for ARM64${NC}"
                echo -e "Binary: ${GREEN}$(pwd)/$BINARY${NC}"
            else
                echo -e "${RED}✗ Warning: Binary is not compiled for ARM64! (Found: $ARCH)${NC}"
                exit 1
            fi
        elif command -v file &> /dev/null; then
            FILE_INFO=$(file "$BINARY")
            if echo "$FILE_INFO" | grep -q "ARM aarch64"; then
                echo -e "${GREEN}✓ Binary is correctly compiled for ARM64${NC}"
                echo -e "Binary: ${GREEN}$(pwd)/$BINARY${NC}"
            else
                echo -e "${YELLOW}File info: $FILE_INFO${NC}"
                echo -e "${YELLOW}Could not verify architecture (readelf not available)${NC}"
            fi
        else
            echo -e "${YELLOW}readelf and file not available, skipping verification${NC}"
        fi
    else
        echo -e "${YELLOW}Warning: Could not find binary to verify${NC}"
        echo -e "${YELLOW}Expected target name: $TARGET_NAME${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Build completed successfully! ===${NC}"
if [ -n "$BINARY" ] && [ -f "$BINARY" ]; then
    echo "Binary location: $(pwd)/$BINARY"
fi
