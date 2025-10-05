#!/bin/bash
#SBATCH -p HaswellPriority
#SBATCH -n 1
srun -l --multi-prog  test1.conf
