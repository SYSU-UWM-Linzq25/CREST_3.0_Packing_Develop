#!/bin/bash
#SBATCH -p debug
#SBATCH -n 6
#SBATCH -x cn297
#SBATCH -o slurm_test.out

echo > slurm_test.out

srun -l --multi-prog  cmd_slurm_test.conf
