#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 150
srun -l --multi-prog  blue_nile_tsd.conf
