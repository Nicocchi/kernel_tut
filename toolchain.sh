#!/bin/bash

BINUTILS_VER=2.44
BINUTILS_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz

GCC_VER=15.1.0
GCC_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz

TARGET=i686-elf
TOOLCHAIN_PREFIX=$PWD/toolchain/$TARGET
PATH="$TOOLCHAIN_PREFIX/bin:$PATH"

BINUTILS_BUILD=$PWD/toolchain/binutils-build-$BINUTILS_VER
GCC_BUILD=$PWD/toolchain/gcc-build-$GCC_VER

mkdir -p toolchain
cd toolchain

function binutils () {
    # Check whether or not we have a completed binutils directory
    if ! test -f $TARGET/bin/$TARGET-ld; then
        if ! test -f binutils-$BINUTILS_VER.tar.xz; then
            echo "--> Downloading Binutils"
            wget $BINUTILS_URL
        fi
        tar -xf binutils-$BINUTILS_VER.tar.xz
        mkdir -p $BINUTILS_BUILD
        cd $BINUTILS_BUILD && ../binutils-$BINUTILS_VER/configure \
                --target=$TARGET				\
                --prefix="$TOOLCHAIN_PREFIX" 	\
                --with-sysroot					\
                --disable-nls					\
                --disable-werror
        echo "--> Finished configuring Binutils"
        echo " "
        echo " "
        make -j8
        echo "--> Finished compiling Binutils"
        echo " "
        echo " "
        make install
        cd ..
        echo "--> Finished intallig binutils"
        echo " "
        echo " "
    fi
}


function gcc () {
    if ! test -f gcc-$GCC_VER.tar.xz; then
        echo "--> Downloading GCC"
        wget $GCC_URL
    fi
    tar -xf gcc-$GCC_VER.tar.xz
    mkdir -p $GCC_BUILD
    cd $GCC_BUILD && ../gcc-$GCC_VER/configure \
        --target=$TARGET				\
        --prefix="$TOOLCHAIN_PREFIX" 	\
        --disable-nls					\
        --enable-languages=c,c++		\
        --without-headers
    echo "--> Finished configuring GCC"
    echo " "
    echo " "
    make -j8 all-gcc all-target-libgcc
    echo "--> Finished compiling GCC"
    echo " "
    echo " "
    make install-gcc install-target-libgcc
    cd ..
    echo "--> Finished intallig GCC"
    echo " "
    echo " "
}

function cleanup () {
    echo "--> Cleaning Up"
    echo " "
    echo " "
    rm -rf binutils-$BINUTILS_VER/
    rm -rf $BINUTILS_BUILD/
}

# Check whether or not we have a compiled gcc compiler
if ! test -f $TARGET/bin/$TARGET-gcc; then
    binutils
    gcc
fi

# Check to make sure gcc is correctly installed
echo "Checking if GCC is compiled correctly."
echo "If you get a successful version output, it is done correctly"
echo " "
$TARGET/bin/$TARGET-gcc --version