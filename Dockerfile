FROM ubuntu:22.04

# Install build tools and cross-compiler for ARM64
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
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
