#!/bin/bash

export DLCIFAR_DATA=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/dl-cifar/datasets/cifar-10-batches-bin/
echo "You probably need to edit variable DLCIFAR_DATA, currently equals $DLCIFAR_DATA"
if [ ! -f "$DLCIFAR_DATA/data_batch_1.bin" ] || [ ! -f "$DLCIFAR_DATA/data_batch_2.bin" ] || [ ! -f "$DLCIFAR_DATA/data_batch_3.bin" ] || [ ! -f "$DLCIFAR_DATA/data_batch_1.bin" ] || [ ! -f "$DLCIFAR_DATA/data_batch_4.bin" ] || [ ! -f "$DLCIFAR_DATA/data_batch_5.bin" ] || [ ! -f "$DLCIFAR_DATA/test_batch.bin" ] || [ ! -f "$DLCIFAR_DATA/batches.meta.txt" ] ; then
    echo "ERROR: you need to download dl-cifar data input from https://www.cs.toronto.edu/~kriz/cifar.html. Read https://github.com/oneapi-src/Velocity-Bench/tree/main/dl-cifar."
    exit 1
fi

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

cd SYCL
rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=icpx cmake -DSYCL_CPU=ON ..
make -j

ONEAPI_DEVICE_SELECTOR=opencl:cpu ./dl-cifar_sycl
