#!/bin/bash

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

mkdir -p deps
cd deps

wget https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.5.tar.gz
tar xf jsoncpp-1.9.5.tar.gz
cd jsoncpp-1.9.5

rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=g++ CC=gcc cmake -DCMAKE_INSTALL_PREFIX=$PWD/install -G Ninja ..
ninja install

