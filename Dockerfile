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
RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
             -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
             -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ && \
    cmake --build .

# Default command
CMD ["./build/HelloWorld"]
