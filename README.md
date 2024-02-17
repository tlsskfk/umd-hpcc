# umd-hpcc
Repository for methods and scripts designed for University of Maryland's HPCC Zaratan Slurm Scheduling System


## Getting Started
You should have a basic understanding of the linux filesystem and shell scripts (environment variables, chmod, etc).
There are 4 directories to be aware of:
1) Home - `/home/$username`
2) Scratch Space - `/scratch/zt1/project/$project_name`
3) Job Space - `/tmp`
You can read through in the [zaratan documentation](https://hpcc.umd.edu/hpcc/help/storage.html#data)

You will start in home, and I recommend creating the following script:

	#!/bin/bash
	project_name="INSERT YOUR PROJECT NAME HERE"
	cd /scratch/zt1/project/$project_name/shared/slurm

And running `chmod +x scratch.sh` so you can do `source scratch.sh` and go directly to the directory the functions of the project is in, as typing out the whole directory is tedious.

The home directory should be private and not for anyworkload.
The Job space can be any temporary workload for the job.
The Scratch Space is the only space available to the jobs for read access, so if you need files or executables, you should reference this space or copy the file to `/tmp` situationally.
Any job nodes will also not have access to the internet while running the job, so make sure to have any files needed accessible in `/tmp` or the shared scratch space.

### Variables
Most variables are set at the top level of the file so that you can adjust it as per your project.
#### Explanations: 
project_name: Recommended to be a short acronym (ex: ntr, fad, hgp).  This is not referring to the name of the folder in the scratch space of the project.


## Home Directory

The home directory here is just to localize our filesystem with /fmriprep in a readable format.  The extraneous env statements help pull the variable from one abstraction to the other.

#### WARNING!!!
For some reason, the hpcc environment will force $HOME to be /home/username, even if you attempt to set it.  Therefore, you must have the templateflow home variable, as the unless you want the templateflow home directory to be /home/username (Not recommended, as you only have 1 gb of space here).


#### Working Directory

A temporary folder will be used for the working directory during each job, at `/tmp`
This directory is local to the nodes that are running the jobs.  You may also use `/scratch/zt1/project/$project_name/shared`, but you may run into storage issues.
