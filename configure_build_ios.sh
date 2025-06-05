#!/bin/bash

APP_NAME="QtApp.app"
QT_VERSION="6.9.1"
BUILD_DIR="./build"
QT_INSTALL_BASE_DIR="${HOME}/Qt2"

QT_CMAKE_DIR="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/ios/lib/cmake"
MAC_DEPLOY_QT="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/ios/bin/macdeployqt"

# Using the latest Qt version
#brew install aqtinstall
#aqt install-qt mac desktop ${QT_VERSION} clang_64 --outputdir ${QT_INSTALL_BASE_DIR}

# Maybe better to install by modules rather than a complete install
#aqt list-qt mac desktop --long-modules 6.9.1 clang_64
aqt install-qt mac ios ${QT_VERSION} ios --outputdir ${QT_INSTALL_BASE_DIR} --modules qtquick3d

# We need cmake
#brew update
#brew upgrade
#brew install cmake

# Make the build folder if not exist
mkdir -p "${BUILD_DIR}"

# RemoveCleaning old CMake build artifacts
rm -f "${BUILD_DIR}/CMakeCache.txt"
rm -rf "${BUILD_DIR}/CMakeFiles"

# Configure cmake
cd "${BUILD_DIR}"
cmake .. -DCMAKE_PREFIX_PATH=${QT_CMAKE_DIR} -DCMAKE_BUILD_TYPE=Release

# Build application
cmake --build . --config Release

# Bundle app with necessary libraries
"${MAC_DEPLOY_QT}" ${APP_NAME} -qmldir=.. --strip
