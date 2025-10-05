#!/bin/bash
#SBATCH -p HaswellPriority
#SBATCH -n 5
srun -l --multi-prog  cmd_Thomaston_in_calib.conf
