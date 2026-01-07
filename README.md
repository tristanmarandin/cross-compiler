# Qt/Qmake Cross-Compiler for ARM64

A complete cross-compilation setup for **ARM64 architecture** (Raspberry Pi CM4 compatible) using **Qt** and **Qmake**. This project supports both simple and complex Qt applications with automatic dependency detection and advanced build configuration.

## Features

- ✅ **Automatic .pro file detection**
- ✅ **Support for complex Qt projects** (QML, Quick, Multimedia, etc.)
- ✅ **Multiple Qt modules** pre-installed
- ✅ **Dependency checking** script
- ✅ **Automatic architecture verification**
- ✅ **Verbose build output** option
- ✅ **Common Qmake configuration** file for reuse

## Supported Qt Modules

The Docker image includes:
- `qtbase5-dev` - Core Qt functionality
- `qtdeclarative5-dev` - QML and Qt Quick
- `qtmultimedia5-dev` - Multimedia support
- `qtsvg5-dev` - SVG support
- `qtcharts5-dev` - Charts and graphs
- `qtserialport5-dev` - Serial port communication
- `qtwebengine5-dev` - WebEngine support
- `qtquickcontrols2-5-dev` - Qt Quick Controls 2

## Building with Docker (Cross-compilation for ARM64)

### Using Docker Compose (recommended)

```bash
docker-compose up --build
```

This will:
1. Build a Docker image with ARM64 cross-compiler tools and Qt/Qmake modules
2. Automatically detect your `.pro` file
3. Compile the project for ARM64 architecture using Qmake
4. Verify the binary is compiled for AArch64

The compiled binary will be available in your local `build/` directory.

### Using Docker directly

```bash
# Build the image
docker build -t qt-cross-compiler .

# Run the container to compile
docker run -v ${PWD}:/app qt-cross-compiler

# The compiled ARM64 binary will be in ./build/
```

### Interactive Docker session

```bash
# Build the image
docker build -t qt-cross-compiler .

# Run an interactive shell
docker run -it -v ${PWD}:/app qt-cross-compiler bash

# Inside the container:
cd /app
./build.sh --verbose
```

## Build Script Usage

The `build.sh` script provides several options:

```bash
./build.sh [options]

Options:
  --clean        Clean build directory before building
  --verbose      Enable verbose output
  --verify       Verify the compiled binary architecture (default)
  --no-verify    Skip architecture verification
  --pro-file     Specify .pro file path (auto-detected if not provided)
  --help         Show help message
```

### Examples

```bash
# Clean build with verbose output
./build.sh --clean --verbose

# Build without verification
./build.sh --no-verify

# Specify custom .pro file
./build.sh --pro-file MyProject.pro
```

## Checking Dependencies

Before building, you can check if all required dependencies are available:

```bash
./check-dependencies.sh
```

This script will:
- Check for cross-compiler tools
- Verify Qt tools (qmake, moc, uic, rcc)
- Detect required Qt modules from your `.pro` file
- Check system libraries

## Project Structure

```
.
├── HelloWorld.pro          # Qmake project file
├── main.cpp                # Main source file
├── build.sh                # Cross-compilation script (auto-detects .pro)
├── check-dependencies.sh   # Dependency checker
├── qmake-common.pri        # Common Qmake config for ARM64 (reusable)
├── Dockerfile              # Docker configuration
├── docker-compose.yml       # Docker Compose configuration
└── build/                  # Build output directory
```

## Using qmake-common.pri

For complex projects, you can include the common configuration:

```pro
# In your .pro file
include(qmake-common.pri)

QT += core gui widgets quick qml

TARGET = MyApp
TEMPLATE = app

SOURCES += main.cpp
```

## Complex Qt Projects

### Example: Qt Quick Application

```pro
QT += core quick qml network

CONFIG += c++17

TARGET = MyQuickApp
TEMPLATE = app

SOURCES += \
    main.cpp \
    src/backend.cpp

HEADERS += \
    src/backend.h

RESOURCES += resources.qrc

# QML files
QML_FILES += \
    qml/main.qml \
    qml/views/HomeView.qml
```

### Example: Multi-module Project

```pro
TEMPLATE = subdirs

SUBDIRS += \
    core \
    gui \
    plugins

core.file = core/core.pro
gui.depends = core
plugins.depends = core gui
```

### Example: Library Project

```pro
QT += core widgets

CONFIG += c++17

TARGET = MyLibrary
TEMPLATE = lib
CONFIG += shared

SOURCES += \
    src/mylibrary.cpp

HEADERS += \
    src/mylibrary.h

# Export headers
target.path = /usr/include
headers.path = /usr/include/MyLibrary
headers.files = $$HEADERS
INSTALLS += target headers
```

## Transferring and Running on Raspberry Pi CM4

After building with Docker, transfer the binary to your Raspberry Pi:

```bash
# Copy the binary to your Raspberry Pi
scp build/MyApp user@raspberry-pi-ip:/path/to/destination/

# Or use any other transfer method (USB, network share, etc.)
```

On the Raspberry Pi, make it executable and run:

```bash
chmod +x MyApp
./MyApp
```

**Note:** For Qt applications with QML or other modules, you may need to install the corresponding Qt runtime libraries on the Raspberry Pi:

```bash
sudo apt-get install qtbase5 qtdeclarative5 qtmultimedia5
```

## Building locally (on Raspberry Pi CM4)

If you want to build directly on the Raspberry Pi:

### Using Qmake (recommended)

```bash
mkdir build
cd build
qmake ..
make
```

### Using g++ directly

```bash
g++ -o MyApp main.cpp -lQt5Core -lQt5Gui -lQt5Widgets
```

## Architecture Verification

To verify the binary is compiled for ARM64:

```bash
readelf -h build/MyApp | grep Machine
# Should output: Machine: AArch64

# Or using file command
file build/MyApp
# Should show: ARM aarch64
```

## Troubleshooting

### Missing Qt Modules

If you need additional Qt modules, add them to the Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y \
    # ... existing packages ...
    qtlocation5-dev \
    qtsensors5-dev
```

### Custom Dependencies

For projects with external dependencies:

1. Add the development packages to the Dockerfile
2. Install cross-compiled libraries in `/usr/aarch64-linux-gnu/`
3. Update `QMAKE_LIBDIR` and `INCLUDEPATH` in your `.pro` file

### Build Errors

- Use `--verbose` flag to see detailed build output
- Check dependencies with `./check-dependencies.sh`
- Ensure your `.pro` file is correctly configured
- Verify that required Qt modules are listed in `QT += ...`

## Advanced Configuration

### Custom Qmake Configuration

Create a custom `.pri` file or modify `qmake-common.pri`:

```pro
# custom-config.pri
QMAKE_CXXFLAGS += -std=c++17 -Wall -Wextra
QMAKE_LFLAGS += -Wl,-rpath,/opt/qt5-arm64/lib
```

Include it in your `.pro` file:

```pro
include(custom-config.pri)
```

### Environment Variables

The build script sets these environment variables:

- `CC=aarch64-linux-gnu-gcc`
- `CXX=aarch64-linux-gnu-g++`
- `PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig`

You can override them before running `build.sh` if needed.
