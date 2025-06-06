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
echo "SOURCE_DIR: ${SOURCE_DIR}"
echo "QT_INSTALL_BASE_DIR: ${QT_INSTALL_BASE_DIR}"
echo "QT_CMAKE_DIR: ${QT_CMAKE_DIR}"
echo "QT_HOST_PATH: ${QT_HOST_PATH}"
echo "IOS_TOOLCHAIN_FILE: ${IOS_TOOLCHAIN_FILE}"

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
    aqt list-qt mac ios --long-modules 6.9.1 ios
    echo "Installing necessary Qt modules"
    # The desktop version of qt also needs to be installed for cross-compilation. Don't use autodesktop option as it installed everything.
    aqt install-qt mac desktop ${QT_VERSION} clang_64 --outputdir ${QT_INSTALL_BASE_DIR} --modules qtquick3d
    aqt install-qt mac ios ${QT_VERSION} ios --outputdir ${QT_INSTALL_BASE_DIR} --modules qtquick3d
else
    echo "Run qt if not already installed"
fi

# Make the build folder if not exist
echo "Make the build folder if not exist"
mkdir -p "${BUILD_DIR}"

# Cleaning old CMake build artifacts
if [ "$CI" = "true" ]; then
    echo "No old CMake build artifacts to clean"
else
    echo "Cleaning old CMake build artifacts"
    rm -f "${BUILD_DIR}/CMakeCache.txt"
    rm -rf "${BUILD_DIR}/CMakeFiles"
fi

# CMake info
cmake --version
cmake -E capabilities

# Configure cmake (get example by configuring a dummy project in QTCreator)
echo "Configuring cmake"
cmake -S${SOURCE_DIR} -B${BUILD_DIR} -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH="${IOS_TOOLCHAIN_FILE}" \
    -DQT_HOST_PATH=${QT_HOST_PATH} \
    -DQT_QML_GENERATE_QMLLS_INI:STRING=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    "-DCMAKE_CXX_FLAGS_DEBUG_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    --no-warn-unused-cli
#    -DCMAKE_OSX_SYSROOT:STRING=iphonesimulator


# Install iOS SDK
if [ "$CI" = "true" ]; then
    echo "Show available SDKs"
    xcodebuild -showsdks
    # Install iOS SDK, make sure the version matches here with the -sdk iphonesimulatorXY.Z in the build command
    echo "Installing iOS SDK"
    xcodebuild -downloadPlatform iOS -buildVersion 18.5
else
    echo "Install necessary iOS SDK if not already installed"
fi

# Move to build folder
echo "Going to build folder"
cd ${BUILD_DIR}

# Build application
echo "Building application"
ARCHS="arm64" xcodebuild \
    -project ${APP_NAME}.xcodeproj \
    build -target ALL_BUILD \
    -parallelizeTargets \
    -configuration ${BUILD_TYPE} \
    -sdk iphonesimulator18.5 \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -jobs 12 \
    -hideShellScriptEnvironment \
    -allowProvisioningUpdates