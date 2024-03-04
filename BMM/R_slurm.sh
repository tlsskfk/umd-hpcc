#!/bin/bash

WDIR="/scratch/zt1/project/jpurcel8-prj/shared/slurm/BMM"
R_SCRIPT="bayesian_trail_b.R"
SLURM_R_SCRIPT="SLURM_$R_SCRIPT"

hash=$(openssl rand -hex 8)
tmp_dir="jpurcel8-$hash"

# Comment the following line out if you plan on running a different script than the one specified above (R_SCRIPT)
# read -p "Which R script would you like to run? " R_SCRIPT

command_string=$(cat <<EOF
#!/bin/bash
#SBATCH -n 1
#SBATCH -t 3-0
#SBATCH -c 10
#SBATCH --mem-per-cpu=2048
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL

module purge
export R_LIBS=~/scratch/R_libs
mkdir -p $R_LIBS
module load r

date 

cd $WDIR

mkdir -p /tmp/$tmp_dir
cp -R $WDIR/* /tmp/$tmp_dir
cd /tmp/$tmp_dir
cat packages.R >>> $SLURM_R_SCRIPT
cat $R_SCRIPT >>> $SLURM_R_SCRIPT

echo "Running R processing with script $R_SCRIPT..."
Rscript --save $SLURM_R_SCRIPT

cp /tmp/$SLURM_JOB_ID/R.R $R_output_dir/output-$SLURM_JOB_ID
echo "scp ../output-$SLURM_JOB_ID/$R_data_wide_dir skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/fmriprep" >> $WDIR/scp.sh
echo "scp ../output-$SLURM_JOB_ID/$R_data_long_dir skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/freesurfer" >> $WDIR/scp.sh
echo "scp ../output-$SLURM_JOB_ID/$R_x2min_dir skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/fmriprep" >> $WDIR/scp.sh

date
EOF
)

# Execute the Slurm script directly without creating a temporary file
sbatch <<< "$command_string"

sleep 2

echo "Successfully Initiated Processing R Script: $R_SCRIPT"

