# Changelog - Qt/Qmake Cross-Compiler Improvements

## Version 2.0 - Support for Complex Qt Projects

### New Features

#### 1. Enhanced Dockerfile
- Added multiple Qt modules:
  - `qtdeclarative5-dev` - QML and Qt Quick support
  - `qtmultimedia5-dev` - Multimedia support
  - `qtsvg5-dev` - SVG support
  - `qtcharts5-dev` - Charts and graphs
  - `qtserialport5-dev` - Serial port communication
  - `qtwebengine5-dev` - WebEngine support
  - `qtquickcontrols2-5-dev` - Qt Quick Controls 2
- Added system libraries:
  - `libssl-dev` - SSL/TLS support
  - `libgl1-mesa-dev` - OpenGL support
  - `libpulse-dev` - Audio support
  - `libasound2-dev` - ALSA audio support
  - `libxkbcommon-dev` - Keyboard handling
- Added utilities:
  - `pkg-config` - Package configuration
  - `file` - File type detection
  - `readelf` - ELF file inspection

#### 2. Advanced Build Script (`build.sh`)
- **Automatic .pro file detection** - No need to specify the project file
- **Target name extraction** - Automatically finds the executable name
- **Qt modules detection** - Analyzes required Qt modules from .pro file
- **Improved error handling** - Better error messages and exit codes
- **Flexible binary detection** - Finds executables in various locations
- **Parallel builds** - Uses `-j$(nproc)` for faster compilation
- **Enhanced verification** - Multiple methods to verify architecture

#### 3. Dependency Checker (`check-dependencies.sh`)
- Checks for cross-compiler tools
- Verifies Qt tools (qmake, moc, uic, rcc)
- Detects required Qt modules from .pro file
- Checks system libraries
- Provides detailed status report

#### 4. Common Qmake Configuration (`qmake-common.pri`)
- Reusable configuration file for ARM64 cross-compilation
- Pre-configured compiler settings
- Library and include paths
- Qt tools paths
- Can be included in any .pro file

#### 5. Enhanced Documentation
- Comprehensive README with examples
- Complex project examples
- Troubleshooting guide
- Advanced configuration options

### Improvements

- Better error messages and diagnostics
- Support for multi-module projects
- Support for library projects
- Support for Qt Quick/QML projects
- Improved build performance with parallel compilation
- Better architecture verification

### Files Added

- `check-dependencies.sh` - Dependency verification script
- `qmake-common.pri` - Common Qmake configuration
- `example-complex.pro` - Example of complex project configuration
- `CHANGELOG.md` - This file

### Files Modified

- `Dockerfile` - Added Qt modules and dependencies
- `build.sh` - Complete rewrite with advanced features
- `README.md` - Comprehensive documentation update
- `docker-compose.yml` - Added dependency checking
- `.gitignore` - Updated to ignore build artifacts

### Breaking Changes

None - The basic usage remains the same, but now supports more complex projects.

### Migration Guide

For existing projects:
1. No changes required for simple projects
2. For complex projects, you can now use additional Qt modules
3. Consider using `qmake-common.pri` for consistency
4. Run `./check-dependencies.sh` to verify your setup

### Usage Examples

```bash
# Basic usage (unchanged)
./build.sh

# With options
./build.sh --clean --verbose

# Check dependencies first
./check-dependencies.sh && ./build.sh
```
