#!/bin/bash

export SAM_DATA=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/SeisAcoMod2D/input
echo "You probably need to edit variable SAM_DATA, currently equals $SAM_DATA"
if [ ! -f "$SAM_DATA/sigsbee2a_cp.bin" ] || [ ! -f "$SAM_DATA/sigsbee2a_den.bin" ] || [ ! -f "$SAM_DATA/twolayer_model_cp.bin" ] || [ ! -f "$SAM_DATA/twolayer_model_den.bin" ]; then
    echo "Directory $SAM_DATA DOES NOT exist - you need to download SAM data input from https://github.com/richaras/SeisAcoMod2D/tree/master/data. Read https://github.com/oneapi-src/Velocity-Bench/tree/main/SeisAcoMod2D"
    exit 1
fi

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

rm -rf data
mkdir data

cp $SAM_DATA/sigsbee2a_cp.bin $SAM_DATA/sigsbee2a_den.bin $SAM_DATA/twolayer_model_cp.bin $SAM_DATA/twolayer_model_den.bin data/

cd SYCL
rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=mpiicpc cmake -DSYCL_CPU=ON ..
make -j

export I_MPI_PMI_LIBRARY=/lib64/libpmi2.so
ONEAPI_DEVICE_SELECTOR=opencl:cpu srun -n 2  ./SeisAcoMod2D ../../input/twoLayer_model_5000x5000z_small.json
