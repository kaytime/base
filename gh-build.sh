#! /bin/bash

ARCH=$1
VERSION=13092022

create_root_fs() {
    GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    BASE_SYSTEM=rootfs_$1_$GIT_CURRENT_BRANCH

    BUILD_DIR=$PWD/$BASE_SYSTEM

    OUTDIR_DIR=$PWD/ouputs

    # Update repository

    apt install debootstrap

    # Create new directory for this work

    mkdir $BUILD_DIR
    mkdir $OUTDIR_DIR

    # Create a base system

    debootstrap --variant=buildd --arch=$ARCH stable $BUILD_DIR

    # Create ROOTFS Archive

    printf "Creating $BASE_SYSTEM... "

    cd "$BUILD_DIR"
    tar -cpf ../"$OUTDIR_DIR/$BASE_SYSTEM" *
    cd ..
    echo "Done!"

    echo "Compressing $BASE_SYSTEM with XZ (using $(nproc) threads)..."
    xz -v --threads=$(nproc) "$BASE_SYSTEM"

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
