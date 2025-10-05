#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 1
srun -l --multi-prog  cmd_CRBIOMonitor.conf
