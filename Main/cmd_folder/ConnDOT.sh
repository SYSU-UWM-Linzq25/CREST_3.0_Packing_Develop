#!/bin/bash
#SBATCH -p HaswellPriority
#SBATCH -n 2
srun -l --multi-prog  cmd_ConnDOT.conf
