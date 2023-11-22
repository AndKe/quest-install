#!/bin/bash

# If no arguments were provided, display usage
if [ $# -eq 0 ]; then
    echo "Usage:quest-install.sh <directory>"
    echo "Example:quest-install.sh 'Some cool homebrew.com'"
    exit 1
fi

# Get the directory name from the first argument
dir=$1

# Check is adb is installed, install if not.
if [ $(dpkg-query -W -f='${Status}' adb 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "You will be asked for pw to install adb"
  sudo apt-get install adb;
fi

# Check if the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    exit 1
fi

# Check if the directory contains exactly one other directory and one .apk file
apk_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.apk" | wc -l)
if [ $apk_count -ne 1 ]; then
    echo "Error: $dir does not contain exactly one .apk file"
    echo "Contents of $dir:"
    ls "$dir"
    exit 1
fi
apk_file=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.apk")

# Get the full path of the directory and the apk file
subdir=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)
dir_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [ $dir_count -ne 1 ]; then
    echo "Found no obb directory, skipping obb copy"
else
    #make directory first needed for Quest3
    echo "-Making obb directory, if exists an error will appear, that is ok."
    adb shell mkdir $(basename "$subdir") /sdcard/Android/obb/

    #Copy obb
    echo "-Copying obb directory"
    adb push "$subdir" /sdcard/Android/obb/
fi


#install apk
echo "-Installing .apk"
adb install -g -r "$apk_file"

echo "-Done"
