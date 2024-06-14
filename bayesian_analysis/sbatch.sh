#!/bin/bash
#SBATCH -n 1
#SBATCH -t 2-0
#SBATCH -c 16
#SBATCH --mem-per-cpu=4096
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL
#export CMDSTAN=$WDIR/packages_extracted/cmdstan-2.34.1
SLURM_JOB_ID=$SLURM_JOB_ID
module purge
#module switch umd-software-library/new
module load openmpi
#module load r/4.3.2/gcc/11.3.0/linux-rhel8-zen2
module load r


date 
echo "Running $R_SCRIPT..."

cd $WDIR

echo "Make a temporary directory for the job"
mkdir -p /tmp/$SLURM_JOB_ID
cp -R $WDIR/$R_DIR /tmp/$SLURM_JOB_ID/
cp $WDIR/*.R /tmp/$SLURM_JOB_ID/
cp $WDIR/*.RDS /tmp/$SLURM_JOB_ID/
cp $WDIR/*.csv /tmp/$SLURM_JOB_ID/
cd /tmp/$SLURM_JOB_ID

echo "Create a new script with the necessary R code for running on zaratan"
cat $packages >> SLURM_R_SCRIPT$script.R
cat "$R_DIR/$CUR_RSCRIPT" >> SLURM_R_SCRIPT$script.R

echo "Running R processing with script $CUR_RSCRIPT..."
export R_LIBS=$WDIR/packages_extracted/
unset R_HOME

Rscript --save ./SLURM_R_SCRIPT$script.R

echo "copy results over to output directory"
cp /tmp/$SLURM_JOB_ID/*.rds $WDIR/$R_DIR

# You will need this if you want to send it to another server
echo "scp $WDIR/$R_DIR/*.rds $WDIR/$R_DIR/*.txt $SCP_OUTPUT_SERVER" >> $WDIR/$R_DIR/scp.sh

sbalance
date
echo "This is the last 25 lines of output from the slurm job associated with $CUR_RSCRIPT" >> $WDIR/$R_DIR/$tmpwd.out
echo "tail -n 25 $WDIR/output-$SLURM_JOB_ID.out >> $WDIR/$R_DIR/$tmpwd.out"
