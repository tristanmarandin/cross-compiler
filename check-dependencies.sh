#!/bin/bash

# Dependency checker for Qt cross-compilation projects
# Checks if required Qt modules and tools are available

# Don't exit on error, we want to check all dependencies
set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Checking Dependencies ==="
echo ""

ERRORS=0
WARNINGS=0

# Check cross-compiler
if command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo -e "${GREEN}✓ Cross-compiler (aarch64-linux-gnu-gcc) found${NC}"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | head -1)
    echo "  $GCC_VERSION"
else
    echo -e "${RED}✗ Cross-compiler (aarch64-linux-gnu-gcc) not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check qmake
if command -v qmake &> /dev/null; then
    echo -e "${GREEN}✓ qmake found${NC}"
    QMAKE_VERSION=$(qmake -v | head -1)
    echo "  $QMAKE_VERSION"
else
    echo -e "${RED}✗ qmake not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check Qt tools
echo ""
echo "Checking Qt tools:"
for tool in moc uic rcc; do
    if command -v $tool &> /dev/null; then
        echo -e "  ${GREEN}✓ $tool found${NC}"
    else
        echo -e "  ${YELLOW}⚠ $tool not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Check Qt modules (if .pro file exists)
PRO_FILE=$(find . -maxdepth 2 -name "*.pro" -type f | grep -v build | head -1)
if [ -n "$PRO_FILE" ]; then
    echo ""
    echo "Checking Qt modules from $PRO_FILE:"
    QT_MODULES=$(grep -E "^QT\s*\+=" "$PRO_FILE" 2>/dev/null | sed 's/QT\s*+=\s*//' | tr ' ' '\n' | grep -v '^$' || true)
    
    if [ -n "$QT_MODULES" ]; then
        for module in $QT_MODULES; do
            # Check if module package is installed
            if dpkg -l 2>/dev/null | grep -q "qt.*$module.*dev"; then
                echo -e "  ${GREEN}✓ Qt module: $module${NC}"
            else
                echo -e "  ${YELLOW}⚠ Qt module: $module (may not be installed)${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        done
    else
        echo -e "  ${YELLOW}No Qt modules specified in .pro file${NC}"
    fi
fi

# Check system libraries
echo ""
echo "Checking system libraries:"
for lib in libssl libgl1-mesa libpulse; do
    if pkg-config --exists $lib 2>/dev/null || ldconfig -p | grep -q $lib; then
        echo -e "  ${GREEN}✓ $lib found${NC}"
    else
        echo -e "  ${YELLOW}⚠ $lib not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All dependencies are available${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Some optional dependencies are missing ($WARNINGS warnings)${NC}"
    exit 0
else
    echo -e "${RED}✗ Critical dependencies are missing ($ERRORS errors, $WARNINGS warnings)${NC}"
    exit 1
fi
