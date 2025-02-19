#!/bin/bash

export HOME="/scratch/zt1/project/jpurcel8-prj/shared"
export SOFTWARE_DIR="$HOME/fmriprep/software"
export BIDS_DIR="$HOME/bids"
export OUTPUT_DIR="$HOME/fmriprep/"
export WORKING_DIR="/tmp"
export LOG_DIR="$HOME/fmriprep/log"

export SINGULARITYENV_TEMPLATEFLOW_USE_PYBIDS=true
export SLURM_EXPORT_ENV=ALL

export DEST_URL="$USER@neurodev3.umd.edu"
export DEST_PATH="/data/neurodev/NTR/fmriprep"

listOfSubjects=""

for subject in "$@"; do
  listOfSubjects+=" \"ntr$subject\""
done

echo "---------------------------------------"
echo "fMRIprep Batch Processing"
echo "Subjects to process: $listOfSubjects"
echo "---------------------------------------"

run_singularity() {
  singularity run -B /scratch/zt1/project/jpurcel8-prj/shared/:/scratch/zt1/project/jpurcel8-prj/shared \
  --home /scratch/zt1/project/jpurcel8-prj/shared \
  --cleanenv /tmp/$1/fmriprep/software/fmriprep-20.2.7.simg \
  --notrack \
  bids ./ \
  participant \
  --participant-label "$1" \
  --work-dir $WORKING_DIR/${USER} \
  --skull-strip-template MNI152NLin2009cAsym \
  --output-spaces MNI152NLin2009cAsym:res-1 \
  --n_cpus 8 \
  --nthreads 8 \
  --omp-nthreads 4 \
  --mem 8G \
  --skip_bids_validation \
  --skull-strip-t1w skip \
  --fs-license-file /tmp/$1/fmriprep/software/license.txt >> "$LOG_DIR/$1.log"
  
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed Processing of subject $1" 
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed Processing of subject $1" >> "$LOG_DIR/$1.log"
}

for subject in "$@"; do
  # Create the command string for Slurm script
  command_string=$(cat <<EOF
#!/bin/bash
#SBATCH -n 1
#SBATCH -t 7-0
#SBATCH -c 8
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL

export SINGULARITYENV_TEMPLATEFLOW_HOME=/tmp/ntr$subject/.cache/templateflow

module purge
module load singularity/3.9.8
module load python/gcc/11.3.0/linux-rhel8-zen2/3.10.10

cd $HOME

mkdir -p /tmp/ntr$subject/fmriprep
mkdir -p /tmp/ntr$subject/.cache
mkdir -p /tmp/fmriprep

cp -r ./fmriprep/software /tmp/ntr$subject/fmriprep
cp -r ./.cache /tmp/ntr$subject

echo "Running Fmriprep processing for ntr$subject..."
$(declare -f run_singularity)
run_singularity "ntr$subject"

echo "Done running subject ntr$subject" 

echo "#-------------------------------" >> $HOME/slurm/${USER}-scp.sh
echo "scp ../fmriprep/sub-ntr$subject.html $DEST_URL:$DEST_PATH/fmriprep" >> $HOME/slurm/${USER}-scp.sh
echo "scp -r ../freesurfer/sub-ntr$subject $DEST_URL:$DEST_PATH/freesurfer" >> $HOME/slurm/${USER}-scp.sh
echo "scp -r ../fmriprep/sub-ntr$subject $DEST_URL:$DEST_PATH/fmriprep" >> $HOME/slurm/${USER}-scp.sh
echo "#-------------------------------" >> $HOME/slurm/${USER}-scp.sh
EOF
)

  # Execute the Slurm script directly without creating a temporary file
  sbatch <<< "$command_string"
done

sleep 2

echo "Successfully Initiated Processing of Subjects: $listOfSubjects"
echo "# Initiated batch: $@" >> $HOME/slurm/${USER}-scp.sh
