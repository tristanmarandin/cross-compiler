FROM ubuntu:22.04

# Install build tools, cross-compiler for ARM64, and Qt/Qmake with additional modules
RUN apt-get update && apt-get install -y \
    build-essential \
    # Qt base and tools
    qtbase5-dev \
    qtbase5-dev-tools \
    # Additional Qt modules for complex projects
    qtdeclarative5-dev \
    qtmultimedia5-dev \
    libqt5svg5-dev \
    libqt5charts5-dev \
    libqt5serialport5-dev \
    qtwebengine5-dev \
    qtquickcontrols2-5-dev \
    # System libraries commonly needed
    libssl-dev \
    libgl1-mesa-dev \
    libpulse-dev \
    libasound2-dev \
    libxkbcommon-dev \
    # Cross-compilation tools
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    # Utilities (readelf is part of binutils)
    pkg-config \
    file \
    binutils \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Make scripts executable and build the project for ARM64
RUN chmod +x build.sh check-dependencies.sh && \
    ./check-dependencies.sh && \
    ./build.sh --verify

# Default command
CMD ["./build/HelloWorld"]
