#!/bin/bash
#SBATCH -N 20
#SBATCH -p ManosLab
#SBATCH --ntasks-per-node=10
srun -l --multi-prog CREST_cmd_CT_River.conf
