# Hello World C++ Project

A simple C++ Hello World project configured for **ARM64 architecture** (Raspberry Pi CM4 compatible).

This project uses **cross-compilation** to build ARM64 binaries from an x86 Docker container, making it easy to compile for Raspberry Pi CM4 without needing the actual hardware.

## Building with Docker (Cross-compilation for ARM64)

### Using Docker Compose (recommended)

```bash
docker-compose up --build
```

This will:
1. Build a Docker image with ARM64 cross-compiler tools
2. Compile the C++ project for ARM64 architecture
3. Verify the binary is compiled for AArch64

The compiled binary (`build/HelloWorld`) will be available in your local directory and can be transferred to your Raspberry Pi CM4.

### Using Docker directly

```bash
# Build the image
docker build -t cpp-helloworld .

# Run the container to compile
docker run -v ${PWD}:/app cpp-helloworld

# The compiled ARM64 binary will be in ./build/HelloWorld
```

### Interactive Docker session

```bash
# Build the image
docker build -t cpp-helloworld .

# Run an interactive shell
docker run -it -v ${PWD}:/app cpp-helloworld bash

# Inside the container, you can then:
cd /app
mkdir -p build
cd build
cmake .. -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
        -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
        -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
cmake --build .
```

## Transferring and Running on Raspberry Pi CM4

After building with Docker, transfer the binary to your Raspberry Pi:

```bash
# Copy the binary to your Raspberry Pi
scp build/HelloWorld user@raspberry-pi-ip:/path/to/destination/

# Or use any other transfer method (USB, network share, etc.)
```

On the Raspberry Pi, make it executable and run:

```bash
chmod +x HelloWorld
./HelloWorld
```

## Building locally (on Raspberry Pi CM4)

If you want to build directly on the Raspberry Pi:

### Using CMake (recommended)

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

### Using g++ directly

```bash
g++ -o HelloWorld main.cpp
```

## Architecture Verification

To verify the binary is compiled for ARM64:

```bash
readelf -h build/HelloWorld | grep Machine
# Should output: Machine: AArch64
```
