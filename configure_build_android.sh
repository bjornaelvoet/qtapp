#!/bin/bash

# Set these variables according to your needs
APP_NAME="QtApp"
BUILD_TYPE_CI="Release"
BUILD_TYPE_LOCAL="Debug"
QT_VERSION="6.9.1"
QT_AQT_HOST_PLATFORM="mac"
QT_AQT_TARGET_OS="android"
QT_AQT_ARCH_ARG="android_arm64_v8a"
QT_FOLDER_NAME="android_arm64_v8a"
QT_REQUIRED_MODULES="qtquick3d"
BUILD_DIR="./build_android"
SOURCE_DIR="."
QT_INSTALL_BASE_DIR="${HOME}/Qt2"


# Android SDK stuff
ANDROID_SDK_PATH="${HOME}/AndroidSDK"
ANDROID_NDK_PATH="${HOME}/AndroidSDK/ndk/26.1.10909125"
ANDROID_TOOLCHAIN_FILE="${ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake"
ANDROID_ABI="arm64-v8a"

# Construct helper paths
QT_CMAKE_DIR="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/android_arm64_v8a/lib/cmake"
QT_HOST_PATH="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos"
QT_ANDROID_TOOLCHAIN_FILE="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake"

# QT helper functions
source "./qt_installer_functions.sh"
# Android SDK helper functions
source "./android_sdk_functions.sh"

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
echo "QT_AQT_HOST_PLATFORM: ${QT_AQT_HOST_PLATFORM}"
echo "QT_AQT_TARGET_OS: ${QT_AQT_TARGET_OS}"
echo "QT_AQT_ARCH_ARG: ${QT_AQT_ARCH_ARG}"
echo "QT_FOLDER_NAME: ${QT_FOLDER_NAME}"
echo "BUILD_DIR: ${BUILD_DIR}"
echo "SOURCE_DIR: ${SOURCE_DIR}"
echo "QT_INSTALL_BASE_DIR: ${QT_INSTALL_BASE_DIR}"
echo "QT_CMAKE_DIR: ${QT_CMAKE_DIR}"
echo "QT_HOST_PATH: ${QT_HOST_PATH}"
echo "QT_ANDROID_TOOLCHAIN_FILE: ${IOS_TOOLCHAIN_FILE}"
echo "DEVELOPER_DIR: ${DEVELOPER_DIR}"
echo "TARGET_SDK: ${TARGET_SDK}"
echo "SDK_PATH: ${SDK_PATH}"

# Check if cmake is already installed
if ! command -v cmake &> /dev/null; then
    echo "cmake is not found."
    echo "Installing cmake via Homebrew..."
    brew update && brew install cmake
else
    echo "cmake is already installed."
fi

# Check if aqt is already installed
if ! command -v aqt &> /dev/null; then
    echo "aqt is not found."
    echo "Installing aqt via Homebrew..."
    brew update && brew install aqtinstall
else
    echo "aqt is already installed."
fi

# Check if sdkmanager is already installed
if ! command -v sdkmanager &> /dev/null; then
    echo "sdkmanager is not found."
    echo "Installing sdkmanager via Homebrew..."
    brew update && brew install sdkmanager
else
    echo "sdkmanager is already installed."
fi

# Install all Android SDK dependenies
echo "Installing Android SDK dependencies"
check_and_install_android_sdk "${ANDROID_SDK_PATH}" "platforms;android-36"
check_and_install_android_sdk "${ANDROID_SDK_PATH}" "build-tools;36.0.0"
check_and_install_android_sdk "${ANDROID_SDK_PATH}" "ndk;26.1.10909125"

# Install all necessary Qt modules
echo "Installing necessary Qt modules"
check_and_install_qt "${QT_VERSION}" \
                     "${QT_AQT_HOST_PLATFORM}" \
                     "${QT_AQT_TARGET_OS}" \
                     "${QT_AQT_ARCH_ARG}" \
                     "${QT_INSTALL_BASE_DIR}" \
                     "${QT_REQUIRED_MODULES}" \
                     "${QT_FOLDER_NAME}"

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
echo "CMake info"
cmake --version
cmake -E capabilities

# Configure cmake (get example by configuring a dummy project in QTCreator)
echo "Configuring cmake"
cmake -S${SOURCE_DIR} -B${BUILD_DIR} \
    -DCMAKE_PREFIX_PATH="${QT_CMAKE_DIR}" \
    -DCMAKE_MODULE_PATH="${QT_CMAKE_DIR}" \
    -DCMAKE_TOOLCHAIN_FILE="${QT_ANDROID_TOOLCHAIN_FILE}" \
    -DQT_CHAINLOAD_TOOLCHAIN_FILE="${ANDROID_TOOLCHAIN_FILE}" \
    -DANDROID_SDK_ROOT="${ANDROID_SDK_PATH}" \
    -DANDROID_NDK_ROOT="${ANDROID_NDK_PATH}" \
    -DANDROID_ABI="${ANDROID_ABI}" \
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
cmake --build . --target apk

# We need the build path exposed to github workflow for artefact upload
if [ "$CI" = "true" ]; then
    echo "BUILD_DIR=${BUILD_DIR##./}" >> $GITHUB_ENV
fi