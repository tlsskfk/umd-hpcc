#!/bin/bash

export HOME="/scratch/zt1/project/jpurcel8-prj/shared"
export SOFTWARE_DIR="$HOME/fmriprep/software"
export BIDS_DIR="$HOME/bids"
export OUTPUT_DIR="$HOME/fmriprep/"
export WORKING_DIR="/tmp/working"
export LOG_DIR="$HOME/fmriprep/log"

export SINGULARITYENV_TEMPLATEFLOW_USE_PYBIDS=true
export SLURM_EXPORT_ENV=ALL

export DEST_URL="skfk@jude.umd.edu"
export DEST_PATH="/data/jude/FAD/fmriprep"

listOfSubjects=""

for subject in "$@"; do
  listOfSubjects+=" \"fad$subject\""
done

echo "---------------------------------------"
echo "fMRIprep Batch Processing"
echo "Subjects to process: $listOfSubjects"
echo "---------------------------------------"

rm $HOME/slurm/scp.sh

run_singularity() {
  singularity run -B /scratch/zt1/project/jpurcel8-prj/shared/:/scratch/zt1/project/jpurcel8-prj/shared \
  --home /scratch/zt1/project/jpurcel8-prj/shared \
  --cleanenv /tmp/$1/fmriprep/software/fmriprep-20.2.7.simg \
  --notrack \
  bids ./ \
  participant \
  --participant-label "$1" \
  --work-dir $WORKING_DIR \
  --skull-strip-template MNI152NLin2009cAsym \
  --output-spaces MNI152NLin2009cAsym:res-1 \
  --n_cpus 16 \
  --nthreads 16 \
  --omp-nthreads 8 \
  --mem 64G \
  --skip_bids_validation \
  --fs-license-file /tmp/$1/fmriprep/software/license.txt >> "$LOG_DIR/$1.log"

  echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed Processing of subject $1" >> "$LOG_DIR/$1.log"
}

for subject in "$@"; do
  # Create the command string for Slurm script
  command_string=$(cat <<EOF
#!/bin/bash
#SBATCH -n 1
#SBATCH -t 1-0
#SBATCH -c 16
#SBATCH --mem-per-cpu=4096
#SBATCH --oversubscribe

export SLURM_EXPORT_ENV=ALL

export SINGULARITYENV_TEMPLATEFLOW_HOME=/tmp/fad$subject/.cache/templateflow

module purge
module load singularity/3.9.8
module load python/zen2/3.8.12

cd $HOME

mkdir -p /tmp/fad$subject/fmriprep
mkdir -p /tmp/fad$subject/.cache
chmod 700 /tmp/fad$subject/fmriprep
chmod 700 /tmp/fad$subject/.cache

cp -r ./fmriprep/software /tmp/fad$subject/fmriprep
cp -r ./.cache /tmp/fad$subject

echo "Running Fmriprep processing for fad$subject..."
$(declare -f run_singularity)
run_singularity "fad$subject"

chmod 777 ../fmriprep/sub-fad$subject.html
chmod 777 -R ../freesurfer/sub-fad$subject
chmod 777 -R ../fmriprep/sub-fad$subject

echo "scp ../fmriprep/sub-fad$subject.html $DEST_URL:$DEST_PATH/fmriprep" >> $HOME/slurm/scp.sh
echo "scp -r ../freesurfer/sub-fad$subject $DEST_URL:$DEST_PATH/freesurfer" >> $HOME/slurm/scp.sh
echo "scp -r ../fmriprep/sub-fad$subject $DEST_URL:$DEST_PATH/fmriprep" >> $HOME/slurm/scp.sh

EOF
)

  # Execute the Slurm script directly without creating a temporary file
  sbatch <<< "$command_string"
done

sleep 2

echo "Successfully Initiated Processing of Subjects: $listOfSubjects"

