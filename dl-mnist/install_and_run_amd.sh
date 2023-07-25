#!/bin/bash

export DLMNIST_DATA=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/dl-mnist/datasets/
echo "You probably need to edit variable DLMNIST_DATA, currently equals $DLMNIST_DATA"
if [ ! -f "$DLMNIST_DATA/t10k-images.idx3-ubyte" ] || [ ! -f "$DLMNIST_DATA/t10k-labels.idx1-ubyte" ] || [ ! -f "$DLMNIST_DATA/train-images.idx3-ubyte" ] || [ ! -f "$DLMNIST_DATA/train-labels.idx1-ubyte" ] ; then
    echo "ERROR: you need to download dl-mnist data input from http://yann.lecun.com/exdb/mnist/. Read https://github.com/oneapi-src/Velocity-Bench/tree/main/dl-mnist. Also notice that the files needed end in .idxY-ubyte and not -idxY-ubyte (notice the point)."
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

ONEAPI_DEVICE_SELECTOR=opencl:cpu ./dl-mnist-sycl -conv_algo ONEDNN_AUTO
