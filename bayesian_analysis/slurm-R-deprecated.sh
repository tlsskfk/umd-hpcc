#!/bin/bash

SCP_OUTPUT_SERVER="skfk@jude.umd.edu:/data/jude/HCP/HCP-Bayesian-Analysis"
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

SLURM_JOB_ID=$SLURM_JOB_ID
echo $SLURM_JOB_ID

module purge
export R_LIBS=~/scratch/R_libs
mkdir -p $R_LIBS
module load r

date 
echo "Running $R_SCRIPT..."

cd $WDIR

# Make a temporary directory for the job
mkdir -p /tmp/$tmpwd
cp -R $WDIR/* /tmp/$tmpwd/
cd /tmp/$tmpwd

# Create a new script with the necessary R code for running on zaratan
cat packages.R >> SLURM_R_SCRIPT$script.R
cat "$R_DIR/$CUR_RSCRIPT" >> SLURM_R_SCRIPT$script.R

echo "Running R processing with script $CUR_RSCRIPT..."
Rscript --save ./SLURM_R_SCRIPT$script.R

# copy results over to output directory
cp /tmp/$tmpwd/*.rds $WDIR/$R_DIR

# You will need this if you want to send it to another server
echo "scp $WDIR/$R_DIR/*.rds $WDIR/$R_DIR/*.txt $SCP_OUTPUT_SERVER" >> $WDIR/$R_DIR/scp.sh

echo "This is the last 25 lines of output from the slurm job associated with $CUR_RSCRIPT" >> $WDIR/$R_DIR/$tmpwd-output.txt
balance >> $WDIR/$R_DIR/$tmpwd-output.txt
# The following line needs to be run post job
echo "tail -n 25 $WDIR/output-$SLURM_JOB_ID >> $WDIR/$R_DIR/$tmpwd-output.txt"

EOF
)

for script in "${listOfScripts[@]}"; do
  # Execute the Slurm script directly without creating a temporary file
  export CUR_RSCRIPT="yi_$script.R"
  export tmpwd="yi_$script"
  sbatch <<< "$command_string"
  sleep 2 
done

echo "Successfully Initiated Processing R Scripts: $R_SCRIPTS"

