#!/bin/bash
#SBATCH -N 52
#SBATCH -p ManosLab
#SBATCH --ntasks-per-node=4
srun -l --multi-prog cmd_CT_NLDAS_c.conf
