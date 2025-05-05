#!/bin/bash

# This script to to clean up any ntr subject
# change ntr to fad as needed

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Loop over all arguments passed to the script
for arg in "$@"
do
    rm -f "$SCRIPT_DIR/../fmriprep/sub-ntr${arg}.html"
    rm -rf "$SCRIPT_DIR/../fmriprep/sub-ntr${arg}"
    rm -rf "$SCRIPT_DIR/../freesurfer/sub-ntr${arg}"
    rm -f  "$SCRIPT_DIR/../fmriprep/log/ntr${arg}.log"
    rm -rf "$SCRIPT_DIR/../bids/sub-ntr${arg}"
done
