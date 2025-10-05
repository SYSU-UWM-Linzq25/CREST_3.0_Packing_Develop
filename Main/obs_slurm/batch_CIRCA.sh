#!/bin/bash
#SBATCH -N 1
#SBATCH -p ManosLab
#SBATCH --ntasks-per-node=1
srun -l --multi-prog  cmd_CIRCA.conf
