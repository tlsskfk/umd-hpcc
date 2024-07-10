# How to Run a fmriprep Job

## Setup
#### Recommended Setup Step
Go to zaratan and I would suggest you post this command into the command line

	echo "cd /scratch/zt1/project/jpurcel8-prj/shared/slurm" > cat.sh

This will create a script that will move you to the slurm directory. otherwise you can type out `cd /path/to/where/you/wanna/go/but/this/takes/alot/of/time`

then do

	source cat.sh

`source` executes a script within the shell session you are currently in.
This will take you to the directory we want to be in, with all the slurm stuff (for your convienence).
This is called our scratch directory, and pretty much everything is going to be here.

You will see a file called `slurm-fad-noskullstrip.sh` and you will use that script or similar to run subjects

## Bids / Subjects

You can see the subjects from this directory by doing

	ls ../bids

and you will see some subjects there that need to be run.
If the subjects are not here, you will need to move them here by going to the location, then executing the following command:
	scp ./path/to/bids/sub-abc1234 username@login.zaratan.umd.edu:/scratch/zt1/project/jpurcel8-prj/shared/slurm/bids/

<bold>Make sure to change the username to your username and the path/to/bids/sub-abc1234 appropriately.</bold>

## Running a Job

You just need to do the following command 

	source slurm-fad-noskullstrip.sh 1234

sometimes it takes a second for the job to queue and start
you can check using the command

	squeue -u skfk

<bold>replace skfk with the username you used to login</bold>


Once the job starts, you should see a slurm-123456.out in the current directory.
This will concern the job.
If you see no errors, you can proceed to checking the log file.
If it doesn't look like this [example](./slurm/slurm-1234567.out.example) then something bad probably happened.
Try the `squeue` command again.  If the job is no longer running, something for sure bad happened.

The next log you can check will exist in the following directory, 

	../scratch/zt1/project/jpurcel8-prj/shared/fmriprep/log/abc1234.log

You can observe this [example](./fmriprep/log/abc1234.log.example)
Do the following command to get a live feed of the log file:

	tail -f ../fmriprep/log/abc1234.log

<bold>Make sure to replace the `abc1234.log` with your subject name</bold>
BTW, you can escape `tail -f` by doing ctrl+c`
You should see the log output to the terminal (sometimes it takes a bit).
If not, check out the previous troubleshooting steps.

If everything looks fine let it sit for around 24 hours and when it is finished there should be outputs from scp.sh in that same directory like

	scp ../fmriprep/sub-fad1229.html skfk@jude.umd.edu:/data/jude/FAD/fmriprep/fmriprep
	scp -r ../freesurfer/sub-fad1229 skfk@jude.umd.edu:/data/jude/FAD/fmriprep/freesurfer
	scp -r ../fmriprep/sub-fad1229 skfk@jude.umd.edu:/data/jude/FAD/fmriprep/fmriprep

find your subject and copy and paste it into the command line to send it back to jude.
Make sure that the slurm output looks good.
There should be a clear 'job has finished' message at the end.

## Final steps
### 1. Changing Destination Permissions

Changing permissions of the files at destination

ssh jude from zaratan (or ssh username@jude.umd.edu)
Move to the directory that you sent files to `/data/jude/FAD/fmriprep/fmriprep`
and `/data/jude/FAD/fmriprep/freesurfer`

Look for your files using

	ls -la

You should see that your newly moved files have different permissions.  This will prevent other people from using the files.

Do the following command in both the `fmriprep` and `freesurfer` folders.

	chmod +777 * -R

(add all permissions to everyone in all files, recursively)
(This is okay because we want everything to be accessible by everyone and you can't change permissions of anyone else anyways)
(you might see some error messages)

You can check the check your files afterwards with

	ls -la

It should change color and you should be able to tell that the permissions have changed.

### 2. Cleaning up
In the original zaratan server, cleanup the folder `fmriprep/sub-abc1234` and `freesurfer/sub-abc1234` and file `fmriprep/sub-abc1234.html` with `rm -rf fmriprep/sub-abc1234 && rm -rf freesurfer/sub-abc1234`
This should be findable from the shared folder

Done! :)
