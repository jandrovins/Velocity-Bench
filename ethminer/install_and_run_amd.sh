#!/bin/bash

export ETHMINER_DEPS=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/ethminer/deps
echo "You probably need to edit variable DLMNIST_DATA, currently equals $DLMNIST_DATA"
if [[ ! -d $ETHMINER_DEPS ]] || [[ ! -d $ETHMINER_DEPS/boost_1_82_0 ]] || [[ ! -d $ETHMINER_DEPS/ethash-0.4.3 ]] || [[ ! -d $ETHMINER_DEPS/jsoncpp-1.9.5 ]] ; then
    echo "ERROR: you need to install dependencies, read https://github.com/oneapi-src/Velocity-Bench/tree/main/ethminer."
    exit 1
fi

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

export Boost_DIR=$ETHMINER_DEPS/boost_1_82_0
export ethash_DIR=$ETHMINER_DEPS/ethash-0.4.3
export jsoncpp_DIR=$ETHMINER_DEPS/jsoncpp-1.9.5
export OPENSSL_ROOT_DIR=/apps/OPENSSL/1.1.1f/GCC/

rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=icpx CC=icx cmake -G Ninja -DETHASHCUDA=OFF -DETHASHSYCL=ON -DSYCL_CPU=ON ..
ninja

ONEAPI_DEVICE_SELECTOR=opencl:cpu ./ethminer/ethminer -S -M 1 --sy-block-size 1024
