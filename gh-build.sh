#! /bin/bash

ARCH=$1
VERSION=13092022

GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

OUTDIR_DIR=$PWD/ouputs

mkdir $OUTDIR_DIR

create_root_fs() {
    # Update repository

    apt install debootstrap

    # Create new directory for this work

    BASE_SYSTEM=rootfs_$1_$GIT_CURRENT_BRANCH

    BUILD_DIR=$PWD/$BASE_SYSTEM

    mkdir $BUILD_DIR

    # Create a base system

    debootstrap --variant=buildd --arch=$ARCH stable $BUILD_DIR

    # Create ROOTFS Archive

    printf "Creating $BASE_SYSTEM... "

    cd "$BUILD_DIR"
    tar -cpf ../"$BASE_SYSTEM.tar" *
    cd ..

    mv $BASE_SYSTEM.tar "$OUTDIR_DIR/$BASE_SYSTEM.tar"
    echo "Done!"

    echo "Compressing $BASE_SYSTEM with XZ (using $(nproc) threads)..."
    xz -v --threads=$(nproc) "$OUTDIR_DIR/$BASE_SYSTEM.tar"

    echo "Successfully created $BASE_SYSTEM.xz."
}

# Execute base file system creation
if [ "$ARCH" != "" ]; then
    for entry in $ARCH; do
        create_root_fs $entry
    done
else
    echo "Please give list of architecture"
fi

ls -a ouputs
