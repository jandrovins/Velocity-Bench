#!/bin/bash

export RTM_DATA=/gpfs/projects/bsc15/bsc15889/Velocity-Bench/reverse_time_migration/data
echo "You probably need to edit variable RTM_DATA, currently equals $RTM_DATA"

if [ ! -d "$RTM_DATA" ]; then
    echo "Directory $RTM_DATA DOES NOT exist - you need to download reverse_time_migration data input using prerequisites/data-download/download_bp_data_iso.sh script"
    exit 1
fi

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh


rm -rf ./bin
CXX="icpx --gcc-toolchain=/apps/GCC/10.2.0/ -g" CC=icx cmake -DCMAKE_BUILD_TYPE=NOMODE -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DUSE_DPC=ON -DUSE_NVIDIA_BACKEND=OFF -DGPU_AOT= -DUSE_CUDA=OFF -DUSE_SM= -DUSE_OpenCV=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF -DDATA_PATH=data -DWRITE_PATH=results -DUSE_INTEL= -DCOMPRESSION=NO -DCOMPRESSION_PATH=. -DUSE_MPI=ON -H. -B./bin

cd bin
make -j
cd ..

cd prerequisites/data-download/
bash download_bp_data_iso.sh

# RUN
taskset -c 0-64 ./make_run.sh dpcpp_cpu
