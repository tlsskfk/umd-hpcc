# umd-hpcc
Repository for methods and scripts designed for University of Maryland's HPCC Zaratan Slurm Scheduling System

## Variables
Most variables are set at the top level of the file so that you can adjust it as per your project.
#### Explanations: 
project_name: Recommended to be a short acronym (ex: ntr, fad, hgp)
`


## Home Directory

The home directory here is just to localize our filesystem with /fmriprep in a readable format.  The extraneous env statements help pull the variable from one abstraction to the other.

WARNING!!!
For some reason, the hpcc environment will force $HOME to be /home/username, even if you attempt to set it.  Therefore, you must have the templateflow home variable, as the unless you want the templateflow home directory to be /home/username (Not recommended).


## Working Directory

Be sure to maintain your working directory between subjects.  10 Subjects should be able to run on 3 TB of space no porblem.  I have tried to use a /tmp directory local to the HPCC worker node, but it gave me issues I was unable to diagnose.  If you figure out why please let me know or make a pull request.
