#!/bin/bash
#SBATCH -N 20
#SBATCH -p ManosLab
#SBATCH --ntasks-per-node=4
srun -l --multi-prog  cmd_CTWest_NLDAS.conf
