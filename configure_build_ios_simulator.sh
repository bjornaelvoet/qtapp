#!/bin/bash

# Set these variables according to your needs
APP_NAME="QtApp"
BUILD_TYPE_CI="Release"
BUILD_TYPE_LOCAL="Debug"
QT_VERSION="6.9.1"
BUILD_DIR="./build"
SOURCE_DIR="."
QT_INSTALL_BASE_DIR="${HOME}/Qt2"

DEVELOPER_DIR_CI="/Applications/Xcode_16.4.app/Contents/Developer"
TARGET_SDK_CI="iphonesimulator18.5"
SDK_PATH_CI="${DEVELOPER_DIR_CI}/Platforms/iPhoneSimulator.platform/Developer/SDKs/${TARGET_SDK_CI}.sdk"

DEVELOPER_DIR_LOCAL="/Applications/Xcode.app/Contents/Developer"
TARGET_SDK_LOCAL="iphonesimulator18.5"
SDK_PATH_LOCAL="${DEVELOPER_DIR_LOCAL}/Platforms/iPhoneSimulator.platform/Developer/SDKs/${TARGET_SDK_LOCAL}.sdk"

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
  export DEVELOPER_DIR=${DEVELOPER_DIR_CI}
  export TARGET_SDK=${TARGET_SDK_CI}
  SDK_PATH=${SDK_PATH_CI}
  BUILD_TYPE=${BUILD_TYPE_CI}
 else
  echo "This script is NOT running in a CI environment."
  export DEVELOPER_DIR=${DEVELOPER_DIR_LOCAL}
  export TARGET_SDK=${TARGET_SDK_LOCAL}
  SDK_PATH=${SDK_PATH_LOCAL}
  BUILD_TYPE=${BUILD_TYPE_LOCAL}
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
echo "DEVELOPER_DIR: ${DEVELOPER_DIR}"
echo "TARGET_SDK: ${TARGET_SDK}"
echo "SDK_PATH: ${SDK_PATH}"

# Check Xcode version is available
echo "Available Xcode versions"
ls -F /Applications | grep "Xcode"
# Check if the path exists before setting DEVELOPER_DIR
if [ -d "$DEVELOPER_DIR" ]; then
    echo "Found Xcode at: $DEVELOPER_DIR"
else
    echo "Error: Xcode installation not found at $DEVELOPER_DIR"
    exit 1 # Fail the workflow if the desired Xcode is not found
fi

echo "CMake will use SDK Sysroot: ${SDK_PATH}"
# Verify the calculated SDK path exists before passing to CMake
if [ ! -d "$SDK_PATH" ]; then
    echo "Error: The calculated SDK path for CMake does not exist: $SDK_PATH"
    echo "Please ensure your DEVELOPER_DIR and TARGET_SDK values are correct and the SDK is installed."
    exit 1
fi

echo "Current Xcode version"
xcode-select --print-path
xcodebuild -version

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
    -DQT_HOST_PATH="${QT_HOST_PATH}" \
    -DQT_QML_GENERATE_QMLLS_INI:STRING=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    "-DCMAKE_CXX_FLAGS_DEBUG_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    "-DCMAKE_OSX_SYSROOT:STRING=${SDK_PATH}" \
    --no-warn-unused-cli

# Move to build folder
echo "Going to build folder"
cd ${BUILD_DIR}

# Build application
echo "Building application"
xcodebuild \
    -project ${APP_NAME}.xcodeproj \
    build -target ALL_BUILD \
    -parallelizeTargets \
    -configuration ${BUILD_TYPE} \
    -sdk ${TARGET_SDK} \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -jobs 12 \
    -hideShellScriptEnvironment \
    -allowProvisioningUpdates \
    ONLY_ACTIVE_ARCH=NO

echo "Xcode build command completed."