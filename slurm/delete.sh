#!/bin/bash

# This script to to clean up any fad subject
# change fad to ntr as needed

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Loop over all arguments passed to the script
for arg in "$@"
do
    rm -f "$SCRIPT_DIR/../fmriprep/sub-fad${arg}.html"
    rm -rf "$SCRIPT_DIR/../fmriprep/sub-fad${arg}"
    rm -rf "$SCRIPT_DIR/../freesurfer/sub-fad${arg}"
    rm -f  "$SCRIPT_DIR/../fmriprep/log/fad${arg}.log"
done
