#!/bin/bash

module load ninja/1.11.1 gcc/10.2.0 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

cd SYCL
rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=icpx cmake -DSYCL_CPU=ON ..
make -j
taskset -c 0-64 ./hashtable_sycl --no-verify
