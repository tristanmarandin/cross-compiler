FROM ubuntu:22.04

# =========================
# 1. Toolchain & deps
# =========================
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    wget \
    perl \
    python3 \
    git \
    dos2unix \
    ca-certificates \
    bison \
    flex \
    gperf \
    pkg-config \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# =========================
# 2. Download Qt sources
# =========================
WORKDIR /tmp
ARG QT_VERSION=5.15.12
ENV QT_VERSION=${QT_VERSION}
# Note: The extracted directory name is qt-everywhere-src-${QT_VERSION} (without "opensource")
ENV QT_SRC_DIR=qt-everywhere-src-${QT_VERSION}

RUN wget https://ftp.fau.de/qtproject/archive/qt/5.15/${QT_VERSION}/single/qt-everywhere-opensource-src-${QT_VERSION}.tar.xz && \
    echo "=== Archive size ===" && \
    ls -lh qt-everywhere-opensource-src-${QT_VERSION}.tar.xz && \
    echo "=== First 100 entries in archive ===" && \
    tar -tf qt-everywhere-opensource-src-${QT_VERSION}.tar.xz | head -100 && \
    echo "=== Extracting archive ===" && \
    tar -xf qt-everywhere-opensource-src-${QT_VERSION}.tar.xz && \
    echo "=== Checking what was extracted ===" && \
    ls -la /tmp/ | grep qt && \
    echo "=== Root directory contents ===" && \
    ls -la /tmp/${QT_SRC_DIR}/ && \
    echo "=== Looking for configure script in root ===" && \
    find /tmp/${QT_SRC_DIR}/ -maxdepth 1 -name "configure" -type f && \
    echo "=== Checking configure directory contents ===" && \
    ls -la /tmp/${QT_SRC_DIR}/qtbase/configure/ 2>/dev/null | head -10 || echo "configure directory doesn't exist or is empty" && \
    rm qt-everywhere-opensource-src-${QT_VERSION}.tar.xz


# =========================
# 3. Configure & build Qt Core (static, ARM64)
# =========================

COPY mkspecs/linux-aarch64-g++ \
     /tmp/${QT_SRC_DIR}/qtbase/mkspecs/devices/linux-aarch64-g++

WORKDIR /tmp/${QT_SRC_DIR}
RUN ./configure \
    -prefix /opt/qt-arm64 \
    -release \
    -static \
    -opensource \
    -confirm-license \
    -no-gui \
    -no-widgets \
    -no-opengl \
    -no-dbus \
    -nomake examples \
    -nomake tests \
    -device linux-aarch64-g++ \
    -device-option CROSS_COMPILE=aarch64-linux-gnu- \
    -skip qtmultimedia \
    -skip qtlocation \
    -skip qtserialport \
    -skip qtwayland \
    -skip qtwebengine \
    && make -j1 V=1 \
    && make install

# Cleanup
RUN rm -rf /tmp/${QT_SRC_DIR}

# =========================
# 4. Build your application
# =========================
WORKDIR /app
COPY . .

ENV PATH=/opt/qt-arm64/bin:$PATH

RUN if [ -f build.sh ]; then \
        dos2unix build.sh 2>/dev/null || sed -i 's/\r$//' build.sh; \
        chmod +x build.sh; \
        ./build.sh --verify; \
    else \
        echo "Error: build.sh not found!" && exit 1; \
    fi

CMD ["./build/HelloWorld"]
