#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 200
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_CRB_MRMS_Agg_StIV.conf
