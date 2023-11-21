#!/bin/bash

# Function that displays usage
function usage() {
    echo "Usage:quest-install.sh <directory>"
    echo "Example:quest-install.sh "Some cool homebrew"
    exit 1
}

# If no arguments were provided, display usage
if [ $# -eq 0 ]; then
    usage
fi

# Get the directory name from the first argument
dir=$1

# Check if the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    exit 1
fi

# Check if the directory contains exactly one other directory and one .apk file
dir_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
apk_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.apk" | wc -l)

if [ $dir_count -ne 1 ] || [ $apk_count -ne 1 ]; then
    echo "Error: $dir does not contain exactly one directory and one .apk file"
    echo "Contents of $dir:"
    ls "$dir"
    exit 1
fi

# Get the full path of the directory and the apk file
subdir=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)
apk_file=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.apk")

#make directory first needed for Quest3
echo "making odd directory, if exists an error will appear, that's ok."
adb shell mkdir $(basename "$subdir") /sdcard/Android/obb/

#Copy obb
echo "Copying obb directory"
adb push "$subdir" /sdcard/Android/obb/

#install apk
echo "Installing .apk"
adb install -g -r "$apk_file"

echo "Done"
