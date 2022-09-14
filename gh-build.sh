#! /bin/bash

ARCH=$1
VERSION="0.1.0-alpha"
GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Create new directory for this work

BASE_SYSTEM=rootfs-$GIT_CURRENT_BRANCH-$VERSION-$ARCH
BASE_SYSTEM_LATEST=rootfs-$GIT_CURRENT_BRANCH-latest-$ARCH

BUILD_DIR=$PWD/$BASE_SYSTEM

DISTRO=""

mkdir $BUILD_DIR

# Switch
while :; do
    case $GIT_CURRENT_BRANCH in
    stable)
        DISTRO="stable"
        break
        ;;
    unstable)
        DISTRO="unstable"
        break
        ;;
    testing)
        DISTRO="unstable"
        break
        ;;
    *)
        DISTRO="unstable"
        break
        ;;
    esac
done

# Update repository

apt install debootstrap

# Create a base system
printf "Creating $BASE_SYSTEM... "

debootstrap --variant=buildd --arch=$ARCH $DISTRO $BUILD_DIR

# Create ROOTFS Archive

printf "Generating $BASE_SYSTEM archive... "

cd "$BUILD_DIR"
ls -a
tar -cpf ../"$BASE_SYSTEM.tar" *
cd ..
echo "Done!"

echo "Compressing $BASE_SYSTEM with XZ (using $(nproc) threads)..."
xz -v --threads=$(nproc) "$BASE_SYSTEM.tar"

# Creating latest archive

cp "$BASE_SYSTEM.tar.xz" "$BASE_SYSTEM_LATEST.tar.xz"

echo "Successfully created $BASE_SYSTEM.xz."
