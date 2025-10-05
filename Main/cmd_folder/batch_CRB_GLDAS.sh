#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 1
#SBATCH -x cn198,cn279,cn297,cn299
srun -l --multi-prog  cmd_CRB_GLDAS.conf
