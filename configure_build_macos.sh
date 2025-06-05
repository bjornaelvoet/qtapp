#!/bin/bash

# Set these variables according to your needs
APP_NAME="QtApp.app"
BUILD_TYPE="Debug"
QT_VERSION="6.9.1"
BUILD_DIR="./build"
QT_INSTALL_BASE_DIR="${HOME}/Qt2"

# Construct helper paths
QT_CMAKE_DIR="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos/lib/cmake"
MAC_DEPLOY_QT="${QT_INSTALL_BASE_DIR}/${QT_VERSION}/macos/bin/macdeployqt"

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
echo "QT_VERSION: ${QT_VERSION}"
echo "BUILD_DIR: ${BUILD_DIR}"
echo "QT_INSTALL_BASE_DIR: ${QT_INSTALL_BASE_DIR}"
echo "QT_CMAKE_DIR: ${QT_CMAKE_DIR}"
echo "MAC_DEPLOY_QT: ${MAC_DEPLOY_QT}"  

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
    aqt list-qt mac desktop --long-modules 6.9.1 clang_64
    echo "Installing necessary Qt modules"
    aqt install-qt mac desktop ${QT_VERSION} clang_64 --outputdir ${QT_INSTALL_BASE_DIR} --modules qtquick3d
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
echo "Going to build folder"
cd "${BUILD_DIR}"
echo "Configuring cmake"
cmake .. -DCMAKE_PREFIX_PATH=${QT_CMAKE_DIR} -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

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