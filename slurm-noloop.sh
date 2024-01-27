#!/bin/bash
#SBATCH -n 1
#SBATCH -t 0-2
#SBATCH -c 16
#SBATCH --mem-per-cpu=512
#SBATCH --oversubscribe

subject=$1
export HOME="/scratch/zt1/project/jpurcel8-prj/shared"
export SOFTWARE_DIR="$HOME/fmriprep/software"
export BIDS_DIR="$HOME/bids"
export OUTPUT_DIR="$HOME/fmriprep/"
export WORKING_DIR="$HOME/fmriprep/working"
export LOG_DIR="$HOME/fmriprep/log"
export SINGULARITYENV_TEMPLATEFLOW_HOME="$HOME/.cache/templateflow"

export SLURM_EXPORT_ENV=ALL

module purge
module load singularity/3.9.8

cd $HOME

echo "Running Fmriprep processing for ntr$subject..."

singularity run -B $HOME/:$HOME/ \
    -B ${TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/templateflow \
    --home $HOME/ \
    --cleanenv $SOFTWARE_DIR/fmriprep-20.2.7.simg \
    $BIDS_DIR $OUTPUT_DIR \
    participant \
    --notrack \
    --participant-label "ntr$subject" \
    --work-dir $WORKING_DIR \
    --skull-strip-template MNI152NLin2009cAsym \
    --output-spaces MNI152NLin2009cAsym:res-1 \
    --n_cpus 16 \
    --mem 8 \
    --skip_bids_validation \
    --fs-license-file $SOFTWARE_DIR/license.txt >> "$LOG_DIR/ntr$subject.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed Processing of subject ntr$subject" >> "$LOG_DIR/ntr$subject.log"

chmod -R g+w+r "$OUTPUT_DIR"


