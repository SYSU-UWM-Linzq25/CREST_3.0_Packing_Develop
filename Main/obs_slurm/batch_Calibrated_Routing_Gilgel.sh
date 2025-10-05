#!/bin/bash
#SBATCH -p HaswellPreempt                # cluster
#SBATCH -n 1
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297


srun -l --multi-prog  cmd_Calibrated_Routing_Gilgel.conf
