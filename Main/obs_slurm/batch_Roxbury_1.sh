#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 1
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_Roxbury_1.conf
