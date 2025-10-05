#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 5
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_BlueNile_in_calib.conf
