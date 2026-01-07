# Example of a complex Qt project configuration
# This demonstrates how to configure a project with multiple Qt modules

QT += core gui widgets quick qml network multimedia

CONFIG += c++17

TARGET = ComplexApp
TEMPLATE = app

# Sources
SOURCES += \
    main.cpp

# Headers
HEADERS +=

# Resources (if you have .qrc files)
# RESOURCES += resources.qrc

# QML files (if using Qt Quick)
# QML_FILES += \
#     qml/main.qml

# Libraries
# LIBS += -L$$PWD/lib -lmylib

# Include paths
# INCLUDEPATH += $$PWD/include

# Output directory
DESTDIR = $$PWD/../build
