# Cross-compilation script for ARM64 using qmake (PowerShell version)
# Usage: .\build.ps1 [options]
# Options:
#   -Clean      Clean build directory before building
#   -Verbose    Enable verbose output
#   -Verify     Verify the compiled binary architecture
#   -Help       Show this help message

param(
    [switch]$Clean,
    [switch]$Verbose,
    [switch]$Verify = $true,
    [switch]$Help
)

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

if ($Help) {
    Write-Output "Cross-compilation script for ARM64 using qmake"
    Write-Output ""
    Write-Output "Usage: .\build.ps1 [options]"
    Write-Output ""
    Write-Output "Options:"
    Write-Output "  -Clean      Clean build directory before building"
    Write-Output "  -Verbose    Enable verbose output"
    Write-Output "  -Verify     Verify the compiled binary architecture (default)"
    Write-Output "  -NoVerify   Skip architecture verification"
    Write-Output "  -Help       Show this help message"
    Write-Output ""
    Write-Output "Note: This script is intended for use in Docker/Linux environments."
    Write-Output "For Windows, use Docker or WSL to run build.sh"
    Write-Output "The build process uses qmake with the linux-aarch64-g++ spec."
    exit 0
}

$ErrorActionPreference = "Stop"

Write-ColorOutput Green "=== ARM64 Cross-Compilation Build Script (using qmake) ==="
Write-Output ""

# Note: This script is mainly for reference
# Cross-compilation typically requires Docker or WSL on Windows
Write-ColorOutput Yellow "Note: Cross-compilation for ARM64 requires Linux tools and qmake."
Write-ColorOutput Yellow "Please use Docker or WSL to run build.sh instead."
Write-Output ""
Write-Output "To use Docker:"
Write-Output "  docker-compose up --build"
Write-Output ""
Write-Output "Or use WSL and run:"
Write-Output "  ./build.sh"

exit 1
