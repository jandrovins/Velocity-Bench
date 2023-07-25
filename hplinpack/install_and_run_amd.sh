#!/bin/bash

module load ninja/1.11.1 gcc/10.2.0 cmake/3.26.3 oneapi/2023.2.0
. /gpfs/apps/AMD/ONEAPI/2023.0.0.25337/setvars.sh

export ONEAPI_DEVICE_SELECTOR=opencl:cpu

make clean
make -j

cd bin/intel64/
export LD_LIBRARY_PATH=../../src/dpcpp/:$LD_LIBRARY_PATH
OMP_NUM_THREADS=128 OMP_PLACES=numa_domains OMP_PROC_BIND=close ./xhpl


