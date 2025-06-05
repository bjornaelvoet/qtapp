#!/bin/bash

# Set these variables according to your needs
APP_NAME="QtApp"
BUILD_TYPE="Debug"
QT_VERSION="6.9.1"
BUILD_DIR="./build"
SOURCE_DIR="."
QT_INSTALL_BASE_DIR="${HOME}/Qt2"

# Construct helper paths
QT_CMAKE_DIR="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/ios/lib/cmake"
MAC_DEPLOY_QT="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/ios/bin/macdeployqt"
QT_HOST_PATH="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos"
IOS_TOOLCHAIN_FILE="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/ios/lib/cmake/Qt6/qt.toolchain.cmake"

# CI or not
if [ "$CI" = "true" ]; then
  echo "This script is running in a CI environment."
  echo "Specifically, GITHUB_ACTIONS is: ${GITHUB_ACTIONS}"
  echo "Workflow Name: ${GITHUB_WORKFLOW}"
  echo "Run ID: ${GITHUB_RUN_ID}"
 else
  echo "This script is NOT running in a CI environment."
fi

# Show the environment variables
echo "APP_NAME: ${APP_NAME}"
echo "BUILD_TYPE: ${BUILD_TYPE}"
echo "QT_VERSION: ${QT_VERSION}"
echo "BUILD_DIR: ${BUILD_DIR}"
echo "QT_INSTALL_BASE_DIR: ${QT_INSTALL_BASE_DIR}"
echo "QT_CMAKE_DIR: ${QT_CMAKE_DIR}"
echo "MAC_DEPLOY_QT: ${MAC_DEPLOY_QT}"
echo "QT_HOST_PATH: ${QT_HOST_PATH}"

# Install cmake if not already installed
if [ "$CI" = "true" ]; then
    echo "Installing cmake"
    brew update && brew install cmake
else
    echo "Install cmake if not already installed"
fi

# Install aqtinstall if not already installed
if [ "$CI" = "true" ]; then
    echo "Installing aqtinstall"
    brew update && brew install aqtinstall
else
    echo "Install aqtinstall if not already installed"
fi

# Install Qt if not already installed
if [ "$CI" = "true" ]; then
    echo "List of possible Qt modules"
    aqt list-qt mac ios --long-modules 6.9.1 clang_64
    echo "Installing necessary Qt modules"
    aqt install-qt mac ios ${QT_VERSION} ios --outputdir ${QT_INSTALL_BASE_DIR} --modules qtquick3d --autodesktop
else
    echo "Run qt if not already installed"
fi

# Make the build folder if not exist
echo "Make the build folder if not exist"
mkdir -p "${BUILD_DIR}"

# RemoveCleaning old CMake build artifacts
if [ "$CI" = "true" ]; then
    echo "No old CMake build artifacts to clean"
else
    echo "Cleaning old CMake build artifacts"
    rm -f "${BUILD_DIR}/CMakeCache.txt"
    rm -rf "${BUILD_DIR}/CMakeFiles"
fi

# Configure cmake
echo "Configuring cmake"
cmake -G Xcode \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH="${IOS_TOOLCHAIN_FILE}" \
    -DQT_HOST_PATH=${QT_HOST_PATH} \
    -DQT_QML_GENERATE_QMLLS_INI:STRING=ON \
    "-DCMAKE_CXX_FLAGS_DEBUG_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    --no-warn-unused-cli \
    -S${SOURCE_DIR} \
    -B${BUILD_DIR}

# Build application
echo "Going to build folder"
cd "${BUILD_DIR}"
echo "Building application"
xcodebuild \
    -project ${APP_NAME}.xcodeproj \
    -scheme ${APP_NAME} \
    -sdk iphonesimulator \
    -configuration ${BUILD_TYPE} \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

# Bundling application
#if [ "$CI" = "true" ]; then
#    echo "Bundling application and making dmg"
#    "${MAC_DEPLOY_QT}" ${APP_NAME} -qmldir=.. -dmg
#else
#    echo "Bundling application"
#    "${MAC_DEPLOY_QT}" ${APP_NAME} -qmldir=..
#fi