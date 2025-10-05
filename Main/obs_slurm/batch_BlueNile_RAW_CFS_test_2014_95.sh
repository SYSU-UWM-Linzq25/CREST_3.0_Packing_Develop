#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 150
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_BlueNile_RAW_CFS_test_2014_95.conf
