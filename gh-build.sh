#! /bin/bash

ARCH=$1
VERSION=13092022
GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

OUTDIR_DIR=$PWD/ouputs

# Create new directory for this work

BASE_SYSTEM=rootfs_$ARCH_$GIT_CURRENT_BRANCH

BUILD_DIR=$PWD/$BASE_SYSTEM

mkdir $BUILD_DIR

# Update repository

apt install debootstrap

# Create a base system

debootstrap --variant=buildd --arch=$ARCH stable $BUILD_DIR

# Create ROOTFS Archive

printf "Creating $BASE_SYSTEM... "

cd "$BUILD_DIR"
ls -a
tar -cpf ../"$BASE_SYSTEM.tar" *
cd ..
echo "Done!"

echo "Compressing $BASE_SYSTEM with XZ (using $(nproc) threads)..."
xz -v --threads=$(nproc) "$BASE_SYSTEM.tar"

# Moving generated archive

mv $BASE_SYSTEM.tar.xz "$OUTDIR_DIR/$BASE_SYSTEM.tar.xz"

echo "Successfully created $BASE_SYSTEM.xz."
