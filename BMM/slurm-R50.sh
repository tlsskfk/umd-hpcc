#!/bin/bash

SCP_OUTPUT_SERVER="skfk@neurodev3.umd.edu:/data/neurodev/HCP_Analyses/BMM"
WDIR="/scratch/zt1/project/jpurcel8-prj/shared/slurm/BMM"
R_SCRIPTS="1,2,3,4,5,6"
R_DIR="set2"
user="skfk"

IFS="," read -r -a listOfScripts <<< "$R_SCRIPTS"

# Download the necessary packages before the job runs
# You can comment this out after the first time you run the script
# source ./packages.sh

command_string=$(cat <<EOF
#!/bin/bash
#SBATCH -n 1
#SBATCH -t 7-0
#SBATCH -c 16
#SBATCH --mem-per-cpu=4096
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL

module purge
export R_LIBS=~/scratch/R_libs
mkdir -p $R_LIBS
module load r

date 
echo "Running $R_SCRIPT..."

cd $WDIR

# Make a temporary directory for the job
mkdir -p /tmp/$R_DIR
cp -R $WDIR/* /tmp/$R_DIR
cd /tmp/$R_DIR

# Create a new script with the necessary R code for running on zaratan
cat packages.R >> SLURM_R_SCRIPT.R
cat "$R_SCRIPT.R" >> SLURM_R_SCRIPT.R

echo "Running R processing with script $R_SCRIPT..."
Rscript --save ./SLURM_R_SCRIPT.R

rm -r packages

cp /tmp/$R_DIR/*.rds $WDIR/$R_DIR
cp /tmp/$R_DIR/*.csv $WDIR/$R_DIR

# You will need this if you want to send it to another server
# echo "scp ./$R_DIR/* $SCP_OUTPUT_SERVER" >> $WDIR$R_DIR/scp.sh

sbalance
date
echo "This is the last 25 lines of output from the slurm job associated with $CUR_RSCRIPT" >> $WDIR/$R_DIR/output.sh
tail -n 25 $WDIR/output-$SLURM_JOB_ID >> $WDIR/$R_DIR/output.sh

EOF
)

for script in "${listOfScripts[@]}"; do
  # Execute the Slurm script directly without creating a temporary file
  export CUR_RSCRIPT="$script.R"
  echo $CUR_RSCRIPT
  sbatch <<< "$command_string"
done

echo "scp $user@login.zaratan.umd.edu:$WDIR/$R_DIR/*" >> $WDIR/$R_DIR/scp.sh

echo "Successfully Initiated Processing R Scripts: $R_SCRIPTS"

