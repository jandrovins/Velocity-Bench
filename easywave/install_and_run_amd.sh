#!/bin/bash

export EW_DATA=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/easywave/data 
echo "You probably need to edit variable EW_DATA, currently equals $EW_DATA"
[ ! -d "$EW_DATA" ] && echo "Directory $EW_DATA DOES NOT exist - you need to download easywave data input from https://git.gfz-potsdam.de/id2/geoperil/easyWave/-/tree/master/data"

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

cd SYCL
rm -rf build_amd
mkdir build_amd
cd build_amd

CXX=icpx cmake -DUSE_INTEL_CPU=ON ..
make -j
./easyWave_sycl -grid $EW_DATA/grids/e2Asean.grd -source $EW_DATA/faults/BengkuluSept2007.flt -time 120
