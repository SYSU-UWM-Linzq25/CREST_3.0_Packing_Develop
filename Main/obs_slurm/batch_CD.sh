#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 150
#SBATCH --ntasks-per-core 10
#SBATCH -x cn299,cn206
srun -l --multi-prog  cmd_CD.conf
