#!/bin/bash
#BATCH -p HaswellPriority
#SBATCH -n 1
srun -l --multi-prog  cmd_IOMonitor.conf
