#!/bin/bash

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

mkdir -p deps
cd deps

wget https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.bz2
tar xf boost_1_82_0.tar.bz2
cd boost_1_82_0

./bootstrap.sh --prefix=$PWD/install
./b2 -j 128
./b2 install -j 128
