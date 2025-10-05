#!/bin/bash
#SBATCH -p HaswellPreempt                # cluster
#SBATCH -n 150
#SBATCH --ntasks-per-core 10
#SBATCH -J "CREST_sub"

srun -l --multi-prog  cmd_CRB_StageIV_EventBased.conf
