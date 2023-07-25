#!/bin/bash

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

mkdir -p deps
cd deps

wget https://github.com/chfast/ethash/archive/refs/tags/v0.4.3.tar.gz
tar xf ethash-0.4.3.tar.gz
cd ethash-0.4.3

rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=g++ CC=gcc cmake -DCMAKE_INSTALL_PREFIX=$PWD/install -DETHASH_BUILD_TESTS=OFF -G Ninja ..
ninja install
