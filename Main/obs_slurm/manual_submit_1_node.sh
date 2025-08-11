#!/bin/bash
# 
# As a workaround to CREST making SLURM unstable, 4 dedicated Haswell
# nodes have been allocated for running it: cn[265,297-299]

if [[ $(hostname) != cn265 ]]; then
    echo "Error: Please login to cn265 to run this script"
    exit 1
fi

cd /shared/stormcenter/Shen/src/CREST_3.0

source /etc/profile.d/modules.sh
module load matlab/2014b-mdcs hdf5/1.8.12 netcdf/4.2-fortran geos/3.4.2 gdal/1.11.2

SLURM_JOB_NAME=parallel_CTWest_NLDAS.sh \
    SLURM_JOB_NODELIST=cn[265,297-299] \
    SLURM_NTASKS_PER_NODE=20 \
    bash parallel_CTWest_NLDAS.sh
