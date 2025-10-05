#!/bin/bash
#SBATCH -p HaswellPriority                # cluster
#SBATCH -n 

srun -l --multi-prog  cmd_CRB_StageIV.conf
