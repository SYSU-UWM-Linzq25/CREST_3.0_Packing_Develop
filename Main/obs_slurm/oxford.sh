#!/bin/bash
#SBATCH -p HaswellPriority
#SBATCH -n 9
srun -l --multi-prog  cmd_oxford.conf
