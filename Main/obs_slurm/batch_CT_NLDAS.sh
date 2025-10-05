#!/bin/bash
#SBATCH -N 10
#SBATCH -p Atmosphere
#SBATCH --ntasks-per-node=12
srun -l --multi-prog cmd_CT_NLDAS.conf
