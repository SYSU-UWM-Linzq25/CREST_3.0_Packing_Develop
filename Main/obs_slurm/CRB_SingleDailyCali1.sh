#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --ntasks-per-node=5
srun -l --multi-prog  cmd_CRBDailyCali1.conf
