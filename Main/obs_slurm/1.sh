BATCH -p HaswellPriority
#SBATCH -n1
#SBATCH -o output_1
#SBATCH -e error_1
srun nohup matlab -nosplash -nodisplay -r canadianriverresult1
