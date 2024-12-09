#!/bin/sh

# -------------- config --------------

# Uncomment for debugging
set -x

# Set bash script to exit immediately if any commands fail
set -e

# Variables
FRAMEWORK_NAME="libprisma"
if [ $1 ]
then 
    FRAMEWORK_NAME=$1
fi

TEMP_BUILD_PATH="./build"
SIMULATOR_ARCHIVE_PATH="${TEMP_BUILD_PATH}/simulator.xcarchive"
DEVICE_ARCHIVE_PATH="${TEMP_BUILD_PATH}/device.xcarchive"
OUPUT_PATH_DIR="./Poduct"

# For debugging
echo "Framework name: ${FRAMEWORK_NAME}"
echo "Build dir: ${TEMP_BUILD_PATH}"
echo "Simulator arch dir: ${SIMULATOR_ARCHIVE_PATH}"
echo "Device arch dir: ${DEVICE_ARCHIVE_PATH}"

# Remove product folder from previous version of framework
rm -rf "${OUPUT_PATH_DIR}"

# Archive
xcodebuild archive -scheme ${FRAMEWORK_NAME} \
					-destination="simulator" \
					-archivePath "${SIMULATOR_ARCHIVE_PATH}" \
					-sdk iphonesimulator \
					SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme ${FRAMEWORK_NAME} \
					-destination="device" \
					-archivePath "${DEVICE_ARCHIVE_PATH}" \
					-sdk iphoneos \
					SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# XCFramework
mkdir "${OUPUT_PATH_DIR}"
xcodebuild  -create-xcframework \
			-framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
			-framework ${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
			-output ${OUPUT_PATH_DIR}/${FRAMEWORK_NAME}.xcframework

# Distribute
cd ${OUPUT_PATH_DIR} && zip -r ${FRAMEWORK_NAME}.zip ${FRAMEWORK_NAME}.xcframework && cd - > /dev/null
echo "Calculate checksum"
swift package compute-checksum ${OUPUT_PATH_DIR}/${FRAMEWORK_NAME}.zip