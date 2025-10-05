#!/bin/bash
#SBATCH -p HaswellPriority
#SBATCH -n 1
srun -l --multi-prog  cmd_SalmonKill.conf
