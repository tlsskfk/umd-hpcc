# Bayesian analysis R scripts in Zaratan

## Necessary Files
  - `slurm-R.sh`
  - `sbatch.sh`
  - `packages.R`
  - `packages.R`

## Necessary Folders
  - `nameofworkingfolderhere`
  - `packages`

## What you need to change 
Some variables in `slurm-R.sh`

`WDIR` - This should be your working directory.  This is where the majority of your slurm scripts will live
`R_DIR` - This should be a directory in your working directory, that holds the data and scripts for your R job.
`R_SCRIPTS` - This is a list of your R scripts, without the ending `.R` (it gets appended later).  Seperate this by commas.
`user` - This should be your username, and it will be used to name some stuff.

## How it works

After it runs, go into the slurm outputs and copy the script.  This will help you move the output of the job to the right place (as there may be some warnings)


## Packages
Part of the R script writes a packages import R file, and combines it with the original R file.  This is the minimize adjustments of the R script when it arrives to zaratan (as it is typically built for a local environment).
`packages.R` is used for brms and pracma
`packages_new.R` is used for brms, pracma, and cmdstan as a backend 
