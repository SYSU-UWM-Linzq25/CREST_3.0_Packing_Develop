#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 10
#SBATCH --ntasks-per-core 2
#SBATCH -x cn297
srun -l --multi-prog  cmd_BlueNile_Soil_TEST.conf
