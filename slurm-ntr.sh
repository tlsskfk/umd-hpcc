#!/bin/bash

export HOME="/scratch/zt1/project/jpurcel8-prj/shared"
export SOFTWARE_DIR="$HOME/fmriprep/software"
export BIDS_DIR="$HOME/bids"
export OUTPUT_DIR="$HOME/fmriprep/"
export WORKING_DIR="/tmp/fmriprep/working"
export LOG_DIR="$HOME/fmriprep/log"
export SINGULARITYENV_TEMPLATEFLOW_USE_PYBIDS=true
export SLURM_EXPORT_ENV=ALL

listOfSubjects=""

for subject in "$@"; do
  listOfSubjects+=" \"ntr$subject\""
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
  --work-dir fmriprep/working \
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

export SINGULARITYENV_TEMPLATEFLOW_HOME=/tmp/ntr$subject/.cache/templateflow

module purge
module load singularity/3.9.8
module load python/zen2/3.8.12

cd $HOME

mkdir -p /tmp/ntr$subject/fmriprep
mkdir -p /tmp/ntr$subject/.cache
mkdir -p $WORKING_DIR

cp -r ./fmriprep/software /tmp/ntr$subject/fmriprep
cp -r ./.cache /tmp/ntr$subject

echo "Running Fmriprep processing for ntr$subject..."
$(declare -f run_singularity)
run_singularity "ntr$subject"

echo "scp ../fmriprep/sub-ntr$subject.html skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/fmriprep" >> $HOME/slurm/scp.sh
echo "scp -r ../freesurfer/sub-ntr$subject skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/freesurfer" >> $HOME/slurm/scp.sh
echo "scp -r ../fmriprep/sub-ntr$subject skfk@neurodev3.umd.edu:/data/neurodev/NTR/fmriprep/fmriprep" >> $HOME/slurm/scp.sh

EOF
)

  # Execute the Slurm script directly without creating a temporary file
  sbatch <<< "$command_string"
done

sleep 2

echo "Successfully Initiated Processing of Subjects: $listOfSubjects"

