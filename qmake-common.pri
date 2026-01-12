# Common Qmake configuration for ARM64 cross-compilation
# Include this file in your .pro file with: include(qmake-common.pri)

# Cross-compiler settings
QMAKE_CC = aarch64-linux-gnu-gcc
QMAKE_CXX = aarch64-linux-gnu-g++
QMAKE_LINK = aarch64-linux-gnu-g++
QMAKE_LINK_SHLIB = aarch64-linux-gnu-g++
QMAKE_AR = aarch64-linux-gnu-ar cqs
QMAKE_STRIP = aarch64-linux-gnu-strip
QMAKE_OBJCOPY = aarch64-linux-gnu-objcopy
QMAKE_NM = aarch64-linux-gnu-nm -P

# Compiler flags for ARM64 (no sysroot)
QMAKE_CFLAGS += -march=armv8-a
QMAKE_CXXFLAGS += -march=armv8-a
QMAKE_LFLAGS += -march=armv8-a

# Qt tools (host tools - must run on build machine)
QMAKE_RCC = /usr/bin/rcc
QMAKE_MOC = /usr/bin/moc
QMAKE_UIC = /usr/bin/uic
QMAKE_QDBUSCPP2XML = /usr/bin/qdbuscpp2xml
QMAKE_QDBUSXML2CPP = /usr/bin/qdbusxml2cpp

# Platform configuration
QMAKE_PLATFORM = linux
CONFIG += cross_compile
