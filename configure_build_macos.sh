#!/bin/bash

# Set these variables according to your needs
APP_NAME="QtApp.app"
BUILD_TYPE_CI="Release"
BUILD_TYPE_LOCAL="Debug"
QT_VERSION="6.9.1"
QT_AQT_HOST_PLATFORM="mac"
QT_AQT_TARGET_OS="desktop"
QT_AQT_ARCH_ARG="clang_64"
QT_FOLDER_NAME="macOS"
QT_REQUIRED_MODULES="qtquick3d"
BUILD_DIR="./build_macos"
SOURCE_DIR="."
QT_INSTALL_BASE_DIR="${HOME}/Qt2"

# Construct helper paths
QT_CMAKE_DIR="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos/lib/cmake"
MAC_DEPLOY_QT="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos/bin/macdeployqt"

# QT helper functions
source "./qt_installer_functions.sh"

# CI or not
if [ "$CI" = "true" ]; then
  echo "This script is running in a CI environment."
  echo "Specifically, GITHUB_ACTIONS is: ${GITHUB_ACTIONS}"
  echo "Workflow Name: ${GITHUB_WORKFLOW}"
  echo "Run ID: ${GITHUB_RUN_ID}"
  BUILD_TYPE=${BUILD_TYPE_CI}
 else
  echo "This script is NOT running in a CI environment."
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
echo "MAC_DEPLOY_QT: ${MAC_DEPLOY_QT}"

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
cmake --version
cmake -E capabilities

# Configure cmake (get example by configuring a dummy project in QTCreator)
echo "Configuring cmake"
cmake -S${SOURCE_DIR} -B${BUILD_DIR} \
    -DCMAKE_PREFIX_PATH=${QT_CMAKE_DIR} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# Move to build folder
echo "Going to build folder"
cd ${BUILD_DIR}

# Build application
echo "Building application"
cmake --build . --config ${BUILD_TYPE}

# Bundling application
if [ "$CI" = "true" ]; then
    echo "Bundling application and making dmg"
    "${MAC_DEPLOY_QT}" ${APP_NAME} -qmldir=.. -dmg
else
    echo "Bundling application"
    "${MAC_DEPLOY_QT}" ${APP_NAME} -qmldir=..
fi

# We need the build path exposed to github workflow for artefact upload
if [ "$CI" = "true" ]; then
    echo "BUILD_DIR=${BUILD_DIR##./}" >> $GITHUB_ENV
fi