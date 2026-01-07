FROM ubuntu:22.04

# Install build tools, cross-compiler for ARM64, and Qt/Qmake
RUN apt-get update && apt-get install -y \
    build-essential \
    qtbase5-dev \
    qtbase5-dev-tools \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Build the project for ARM64
RUN chmod +x build.sh && \
    ./build.sh --verify

# Default command
CMD ["./build/HelloWorld"]
