#!/bin/bash

export SCP_OUTPUT_SERVER="skfk@jude.umd.edu:/data/jude/HCP/HCP-Bayesian-Analysis"
export WDIR="/scratch/zt1/project/jpurcel8-prj/shared/slurm/BMM"
export R_SCRIPTS="1,2,3,4,5,6"
export R_DIR="set2"
export user="skfk"

IFS="," read -r -a listOfScripts <<< "$R_SCRIPTS"

for script in "${listOfScripts[@]}"; do
  # Execute the Slurm script directly without creating a temporary file
  export CUR_RSCRIPT="$script.R"
  export tmpwd="$user-$script"
  echo "Submitting R job for script $script.R"
  sbatch --export=SCP_OUTPUT_SERVER,WDIR,R_SCRIPTS,R_DIR,user,script,CUR_RSCRIPT,tmpwd ./sbatch.sh
done

echo "Successfully Initiated Processing R Scripts: $R_SCRIPTS"

