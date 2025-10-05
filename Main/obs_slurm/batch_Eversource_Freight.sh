#!/bin/bash
#SBATCH -p HaswellPreempt                # cluster
#SBATCH -n 1
#SBATCH --ntasks-per-core 10
#SBATCH -x cn171,cn172,cn222,cn225,cn230,cn271,cn310,cn316,cn299,cn206
srun -l --multi-prog  cmd_Eversource_Freight.conf