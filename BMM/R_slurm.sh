#!/bin/bash

SCP_OUTPUT_SERVER="skfk@neurodev3.umd.edu:/data/neurodev/HCP_Analyses/BMM"
WDIR="/scratch/zt1/project/jpurcel8-prj/shared/slurm/BMM"
R_SCRIPT="bayesian_trail_b.R"
SLURM_R_SCRIPT="SLURM_$R_SCRIPT"

hash=$(openssl rand -hex 3)
tmp_dir="jpurcel8-$hash"

# Comment the following line out if you plan on running a different script than the one specified above (R_SCRIPT)
# read -p "Which R script would you like to run? " R_SCRIPT

# Download the necessary packages before the job runs
# You can comment this out after the first time you run the script
# source ./packages.sh

command_string=$(cat <<EOF
#!/bin/bash
#SBATCH -n 1
#SBATCH -t 3-0
#SBATCH -c 16
#SBATCH --mem-per-cpu=2048
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL

module purge
export R_LIBS=~/scratch/R_libs
mkdir -p $R_LIBS
module load r

date 

cd $WDIR

# Make a temporary directory for the job
mkdir -p /tmp/$tmp_dir
cp -R $WDIR/* /tmp/$tmp_dir
cd /tmp/$tmp_dir

# Create a new script with the necessary R code for running on zaratan
cat packages.R >> $SLURM_R_SCRIPT
cat $R_SCRIPT >> $SLURM_R_SCRIPT

echo "Running R processing with script $R_SCRIPT..."
Rscript --save ./$SLURM_R_SCRIPT

rm -R packages

# mkdir -p $R_output_dir/output-$hash
cp -R /tmp/$tmp_dir/* $R_output_dir/output-$hash
date >> $WDIR/scp.sh
# echo "scp ../output-$hash/* $SCP_OUTPUT_SERVER" >> $WDIR/scp.sh
date
EOF
)

# Execute the Slurm script directly without creating a temporary file
sbatch <<< "$command_string"

echo "Successfully Initiated Processing R Script: $R_SCRIPT"

