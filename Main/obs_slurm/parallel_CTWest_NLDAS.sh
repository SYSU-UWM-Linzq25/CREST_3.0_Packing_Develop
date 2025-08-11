#!/bin/bash +x
#SBATCH -N 10
#SBATCH -p Haswell
#SBATCH --qos=haswell384
##SBATCH -p Atmosphere
#SBATCH --ntasks-per-node=8

# === GNU Parallel setup ===
# Load the modules
source /etc/profile.d/modules.sh
module load parallel python/3.4.3
# Create the machine file for this job
machine_file=${SLURM_JOB_NAME%.*}.sshloginfile
hostlist -e ${SLURM_JOB_NODELIST} > $machine_file
# Allow export of environment using `--env' option
if [[ ! -e ~/.parallel/ignored_vars ]]; then
    # Create an empty ignored_vars file to pass all the environment
    # variables to the SSH instance
    mkdir -p ~/.parallel
    touch ~/.parallel/ignored_vars
fi
# If no job number is set, use the date
if [[ -z $SLURM_JOB_ID ]]; then
    date=$(date +%Y-%m-%dT%H%M)
    outfile="2>&1 >> manual-${date}.out"
fi
# Pass options to GNU Parallel
parallel="parallel
 --delay 1
 --jobs 80
 --sshloginfile $machine_file
 -j ${SLURM_NTASKS_PER_NODE}
 --env _
 2>&1
"

# === Run MATLAB instances ===
${parallel} "cd $PWD;" matlab -singleCompThread -nojvm -nodesktop -r "\"CREST('/shared/manoslab/CT_West/CT_West_NLDAS35.project','mean',{},80);\" ${outfile}" ::: $(seq 1 80)
