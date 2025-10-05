#!/bin/bash
#SBATCH -p general                # cluster
#SBATCH -n 150
#SBATCH --ntasks-per-core 10
#SBATCH -x cn297
srun -l --multi-prog  cmd_BlueNile_GDAS_IMERG_3_hourly_Orden.conf
