#!/bin/bash

# Script to create a sysroot from a Raspberry Pi CM4 device
# This creates a proper sysroot with the exact libraries and headers from the target device
# Usage: ./create-sysroot-from-cm4.sh [CM4_HOST] [CM4_USER] [SYSROOT_PATH]
#
# Example:
#   ./create-sysroot-from-cm4.sh 192.168.1.100 pi /opt/cm4-sysroot
#
# Requirements:
#   - rsync installed on the host machine
#   - SSH access to the CM4 device
#   - Sufficient disk space (typically 500MB-2GB)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CM4_HOST="${1:-}"
CM4_USER="${2:-pi}"
SYSROOT_PATH="${3:-/opt/cm4-sysroot}"

# Check if rsync is available
if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync not found!${NC}"
    echo "Please install rsync:"
    echo "  sudo apt-get install rsync"
    exit 1
fi

# Check if host is provided
if [ -z "$CM4_HOST" ]; then
    echo -e "${YELLOW}Usage: $0 [CM4_HOST] [CM4_USER] [SYSROOT_PATH]${NC}"
    echo ""
    echo "Arguments:"
    echo "  CM4_HOST    - IP address or hostname of the CM4 device (required)"
    echo "  CM4_USER    - SSH username (default: pi)"
    echo "  SYSROOT_PATH - Path where sysroot will be created (default: /opt/cm4-sysroot)"
    echo ""
    echo "Example:"
    echo "  $0 192.168.1.100 pi /opt/cm4-sysroot"
    exit 1
fi

echo -e "${GREEN}=== Creating CM4 Sysroot ===${NC}"
echo ""
echo "CM4 Host:     $CM4_HOST"
echo "CM4 User:    $CM4_USER"
echo "Sysroot Path: $SYSROOT_PATH"
echo ""

# Check if sysroot path already exists
if [ -d "$SYSROOT_PATH" ]; then
    echo -e "${YELLOW}Warning: Sysroot directory already exists: $SYSROOT_PATH${NC}"
    read -p "Do you want to remove it and create a new one? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing existing sysroot...${NC}"
        sudo rm -rf "$SYSROOT_PATH"
    else
        echo -e "${RED}Aborted.${NC}"
        exit 1
    fi
fi

# Create sysroot directory structure
echo -e "${BLUE}Creating sysroot directory structure...${NC}"
sudo mkdir -p "$SYSROOT_PATH"
sudo chown $USER:$USER "$SYSROOT_PATH"

# Create subdirectories
mkdir -p "$SYSROOT_PATH"/{lib,usr/lib,usr/include,usr/lib/aarch64-linux-gnu,opt,etc}

# Test SSH connection
echo -e "${BLUE}Testing SSH connection to $CM4_USER@$CM4_HOST...${NC}"
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$CM4_USER@$CM4_HOST" "echo 'Connection successful'" 2>/dev/null; then
    echo -e "${YELLOW}Note: SSH key authentication may not be set up.${NC}"
    echo -e "${YELLOW}You may be prompted for a password.${NC}"
fi

# Copy essential system directories
echo ""
echo -e "${GREEN}Copying system libraries and headers from CM4...${NC}"
echo -e "${BLUE}This may take several minutes depending on your connection speed...${NC}"
echo ""

# Copy /lib (system libraries)
echo -e "${BLUE}Copying /lib...${NC}"
rsync -avz --progress \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    "$CM4_USER@$CM4_HOST:/lib/" "$SYSROOT_PATH/lib/" || {
    echo -e "${YELLOW}Warning: Some files in /lib may have failed to copy${NC}"
}

# Copy /usr/lib (user libraries)
echo -e "${BLUE}Copying /usr/lib...${NC}"
rsync -avz --progress \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    --exclude='cmake' \
    --exclude='pkgconfig' \
    "$CM4_USER@$CM4_HOST:/usr/lib/" "$SYSROOT_PATH/usr/lib/" || {
    echo -e "${YELLOW}Warning: Some files in /usr/lib may have failed to copy${NC}"
}

# Copy /usr/include (headers)
echo -e "${BLUE}Copying /usr/include...${NC}"
rsync -avz --progress \
    "$CM4_USER@$CM4_HOST:/usr/include/" "$SYSROOT_PATH/usr/include/" || {
    echo -e "${YELLOW}Warning: Some files in /usr/include may have failed to copy${NC}"
}

# Copy /opt if it exists and contains libraries
echo -e "${BLUE}Checking /opt for custom libraries...${NC}"
if ssh "$CM4_USER@$CM4_HOST" "[ -d /opt ] && [ \"\$(ls -A /opt)\" ]" 2>/dev/null; then
    rsync -avz --progress \
        "$CM4_USER@$CM4_HOST:/opt/" "$SYSROOT_PATH/opt/" || {
        echo -e "${YELLOW}Warning: Some files in /opt may have failed to copy${NC}"
    }
fi

# Copy /etc/ld.so.conf and related files
echo -e "${BLUE}Copying /etc/ld.so.conf...${NC}"
rsync -avz --progress \
    "$CM4_USER@$CM4_HOST:/etc/ld.so.conf" "$SYSROOT_PATH/etc/" 2>/dev/null || true
rsync -avz --progress \
    "$CM4_USER@$CM4_HOST:/etc/ld.so.conf.d/" "$SYSROOT_PATH/etc/ld.so.conf.d/" 2>/dev/null || true

# Fix symlinks that may point to absolute paths
echo -e "${BLUE}Fixing symlinks...${NC}"
find "$SYSROOT_PATH" -type l -lname '/*' | while read link; do
    target=$(readlink "$link")
    # Only fix if target starts with / and is within the sysroot
    if [[ "$target" == /* ]] && [[ ! "$target" == "$SYSROOT_PATH"/* ]]; then
        # Try to find the target within sysroot
        rel_target="${target#/}"
        if [ -e "$SYSROOT_PATH/$rel_target" ]; then
            ln -sf "$rel_target" "$link"
        fi
    fi
done

# Set proper permissions
echo -e "${BLUE}Setting permissions...${NC}"
sudo chown -R root:root "$SYSROOT_PATH" 2>/dev/null || true

# Summary
echo ""
echo -e "${GREEN}=== Sysroot Creation Complete ===${NC}"
echo ""
echo "Sysroot location: $SYSROOT_PATH"
echo ""
echo "Directory structure:"
du -sh "$SYSROOT_PATH"/* 2>/dev/null | head -10 || true
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Update your mkspec or build script to use: QMAKE_SYSROOT=$SYSROOT_PATH"
echo "2. Verify the sysroot contains the libraries you need:"
echo "   ls -la $SYSROOT_PATH/usr/lib/aarch64-linux-gnu/"
echo "3. Rebuild your project with the new sysroot"
echo ""
