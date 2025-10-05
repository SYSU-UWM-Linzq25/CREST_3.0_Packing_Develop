#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 1
#SBATCH -x cn214,cn251,cn320,cn216
srun -l --multi-prog  cmd_01130000_calib.conf
