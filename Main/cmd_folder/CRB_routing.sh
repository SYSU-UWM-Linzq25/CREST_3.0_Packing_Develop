#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 1
#SBATCH -x cn297
srun -l --multi-prog  cmd_CRB_routing.conf
