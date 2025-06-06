#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 -h or $0 --help for more information"
  exit 1
fi

# Help on arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: $0 -b <macos|ios> [options]"
  echo ""
  echo "Required arguments:"
  echo "  -b, --build <macos|ios>     Name of the target to build against"
  echo "Optional arguments:"
  echo "  -h, --help                  Show this help message and exit"
  exit 0
fi

# Default values
BUILD_TARGET=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -b|--build)
    BUILD_TARGET="$2"
    shift 2
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Validate the required arguments
# Validate build argument
if [[ "$BUILD_TARGET" != "ios" && "$BUILD_TARGET" != "macos" ]]; then
  echo "Error: Invalid build target '$BUILD_TARGET'. See help for build targets."
  exit 1
fi

# Determine project source directory
if [ -n "$GITHUB_WORKSPACE" ]; then
  # Running in GitHub Actions
  SOURCE_DIR="$GITHUB_WORKSPACE"
else
  # Running locally. Assume configure.sh is in the project root.
  # Get the absolute path of the directory containing this script.
  SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  source local_env.sh
  case "$BUILD_TARGET" in
  ios)
    QT_ROOT_DIR="${QT_ROOT_DIR_69_IOS}"
    ;;
  macos)
    QT_ROOT_DIR="${QT_ROOT_DIR_69_MACOS}"
    ;;
  *)
    echo "Error: Unknown build target $BUILD_TARGET."
    exit 1
    ;;
  esac
fi

BUILD_DIR="${SOURCE_DIR}/build"

echo "Source directory: ${SOURCE_DIR}"
echo "Build directory: ${BUILD_DIR}"
echo "Qt root directory: ${QT_ROOT_DIR}"

mkdir -p "${BUILD_DIR}"

# QT_ROOT_DIR must be set in the environment.
# For GitHub Actions, 'jurplel/install-qt-action' sets this.
# For local builds, you must set this to your Qt iOS installation path.
# e.g., export QT_ROOT_DIR=/Users/yourname/Qt/6.9.0/ios
if [ -z "${QT_ROOT_DIR}" ]; then
  echo "Error: QT_ROOT_DIR environment variable is not set."
  echo "Please set it to your Qt iOS installation path (e.g., /Users/yourname/Qt/6.9.0/ios for local builds)."
  exit 1
fi

IOS_TOOLCHAIN_FILE="${QT_ROOT_DIR}/lib/cmake/Qt6/qt.toolchain.cmake"
if [ ! -f "${IOS_TOOLCHAIN_FILE}" ]; then
    echo "Error: Qt iOS toolchain file not found at ${IOS_TOOLCHAIN_FILE}"
    echo "Please check your QT_ROOT_DIR or Qt installation."
    exit 1
fi

cmake -G Xcode \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH="${IOS_TOOLCHAIN_FILE}" \
    -DQT_QML_GENERATE_QMLLS_INI:STRING=ON \
    "-DCMAKE_CXX_FLAGS_DEBUG_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT:STRING=-DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" \
    --no-warn-unused-cli \
    -S${SOURCE_DIR} \
    -B${BUILD_DIR}


