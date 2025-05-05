#!/bin/tcsh

# Change to the directory containing the subjects
set base_dir = '/data/jude/FAD/bids_v2'

# List all subdirectories starting with "sub-fad"
set subjects = `ls -d $base_dir/sub-fad*`

# Loop through each subject
foreach subj_path ($subjects)

    # Extract the final directory name (sub-fad####)
    set subj = `basename $subj_path`
    echo 'Starting:' $subj
    
    set datadir = /data/jude/FAD/bids_v2/$subj/ses-bl/anat



    3dSkullStrip -input $datadir/${subj}_ses-bl_acq-1norm_T2w.nii.gz -prefix $datadir/${subj}_ses-bl_acq-1norm_desc-skullstrip_T2w.nii.gz -shrink_fac_bot_lim 0.7

    #3dSkullStrip -input $datadir/${subj}_acq-1norm_T2w.nii -prefix $datadir/${subj}_acq-1norm_desc-skullstrip_T2w.nii -shrink_fac_bot_lim 0.7

    # Uncomment to move the original skullstrip to the misc folder

    mv $datadir/${subj}_ses-bl_acq-1norm_T2w.json $datadir/${subj}_ses-bl_acq-1norm_desc-skullstrip_T2w.json
    mv $datadir/${subj}_ses-bl_acq-1norm_T2w.ni* /data/jude/FAD/bids-misc/misc/$subj/ses-bl/${subj}_ses-bl_acq-1norm_T2w.nii.gz

    echo 'Finished:' $subj

end
