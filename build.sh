#! /bin/bash

### Licence
# This file is base on original Nitrux debrfs
# 2022 (c) Kaytime Labs

set -e

# Run as root or ask user for sudo

(( EUID != 0 )) && exec sudo -- "$0" "$@"


# Define the path of the debrfs configuration file

CONFIG_FILE=$(pwd)/build.conf


# Load values from configuration file
# Include fix for SC1090 – ShellCheck

if [[ ! -f $CONFIG_FILE ]]; then
    echo "Configuration file not found! Exiting..." 2>&1
    exit 1
    else
    echo "Configuration file found! Loading..."
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
fi


# Others configs

ARCH=$1
VERSION="0.1.0-alpha"
GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

BASE_SYSTEM=rootfs-$GIT_CURRENT_BRANCH-$VERSION-$ARCH
BASE_SYSTEM_LATEST=rootfs-$GIT_CURRENT_BRANCH-latest-$ARCH

BASE_SYSTEM_DIR=$(pwd)/$BASE_SYSTEM
BASE_SYSTEM_FILE="$BASE_SYSTEM.tar.xz"

while :; do
    case $GIT_CURRENT_BRANCH in
    stable)
        BASE_CHANNEL=stable
        break
        ;;
    unstable)
        BASE_CHANNEL=unstable
        break
        ;;
    testing)
        BASE_CHANNEL=unstable
        break
        ;;
    *)
        echo "This channel is not supported."
        break
        ;;
    esac
done


# Check if debootstrap is available, if not, install it

# PKG_OK=$(dpkg-query -W --showformat='${Status}\n' "$REQUIRED_PKG"|grep "install ok installed")

# echo Checking for "$REQUIRED_PKG": "$PKG_OK"

# if [ "" = "$PKG_OK" ]; then
#   echo "No $REQUIRED_PKG. Installing $REQUIRED_PKG."
#   apt install "$REQUIRED_PKG"
# fi

apt install "$REQUIRED_PKG"


# Create target directory for rootfs and use debootstrap to add content
# Clean target directory if already present and add content

if [[ ! -d $BASE_SYSTEM_DIR ]]; then
    echo "Directory not found! Creating..." 2>&1
    mkdir -p "$BASE_SYSTEM_DIR"
    debootstrap --variant="$ROOTFS_VARIANT" --exclude="$ROOTFS_EXCLUDE" --arch "$ARCH" --cache-dir=/tmp "$BASE_CHANNEL" "$BASE_SYSTEM_DIR" "$ROOTFS_MIRROR"
    else
    echo "Directory found! Cleaning..."
    rm -rf "$BASE_SYSTEM_DIR" && mkdir -p "$BASE_SYSTEM_DIR"
    debootstrap --variant="$ROOTFS_VARIANT" --exclude="$ROOTFS_EXCLUDE" --arch "$ARCH" --cache-dir=/tmp "$BASE_CHANNEL" "$BASE_SYSTEM_DIR" "$ROOTFS_MIRROR"
fi


# Compress rootfs directory using TAR and XZ

if [[ ! -f $BASE_SYSTEM_FILE ]]; then
    echo "File not found! Creating..." 2>&1
    rm "$BASE_SYSTEM_DIR"/var/cache/apt/archives/*.deb && tar -I 'xz -9' -cvf "$BASE_SYSTEM_FILE" --exclude="$BASE_SYSTEM_DIR/var/cache/apt/archives" -C "$BASE_SYSTEM_DIR" .
    else
    echo "File found! Cleaning..."
    rm -rf "$BASE_SYSTEM_FILE" && rm "$BASE_SYSTEM_DIR"/var/cache/apt/archives/*.deb && tar -I 'xz -9' -cvf "$BASE_SYSTEM_FILE" --exclude="$BASE_SYSTEM_DIR/var/cache/apt/archives" -C "$BASE_SYSTEM_DIR" .
fi


if [ $ARCH == "arm64" ]; then
    cat $(pwd)/rootfs-testing-0.1.0-alpha-arm64/debootstrap/debootstrap.log
fi



# Generated versionned archives

cp "$BASE_SYSTEM_FILE" "$BASE_SYSTEM_LATEST.tar.xz"

echo "Successfully created base system."