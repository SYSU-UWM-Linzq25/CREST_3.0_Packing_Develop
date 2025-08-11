#!/bin/bash
#SBATCH -N 16
#SBATCH -p StormCenter
#SBATCH --ntasks-per-node=8
srun -l --multi-prog silly.conf
