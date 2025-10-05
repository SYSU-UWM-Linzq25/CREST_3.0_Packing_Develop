#!/bin/bash
#SBATCH -p HaswellPreempt                # cluster
#SBATCH -n 6
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_CRB_test.conf
