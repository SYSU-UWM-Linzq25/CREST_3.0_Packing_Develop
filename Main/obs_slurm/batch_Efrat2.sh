#!/bin/bash
#SBATCH -p general                # cluster
#SBATCH -n 10
#SBATCH --ntasks-per-core 5
#SBATCH -x cn297
srun -l --multi-prog  cmd_Efrat2.conf
