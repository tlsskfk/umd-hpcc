#!/bin/bash

read -p "what is your zaratan user id?: " username
read -p "which subjects do you wish to move (separate by ',')?: " subjects
IFS="," read -r -a subjects <<< "$subjects"

# Construct the source paths for each subject
source_paths=()
for subject in "${subjects[@]}"; do
  localsubject="sub-ntr$subject"
  source_paths+=("./$localsubject")
done

# Construct the destination path
destination_path="$username@login.zaratan.umd.edu:/scratch/zt1/project/jpurcel8-prj/shared/bids"

# Perform a single scp command for all subjects
scp -r "${source_paths[@]}" "$destination_path"

