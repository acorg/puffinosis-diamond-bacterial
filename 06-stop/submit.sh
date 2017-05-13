#!/bin/bash -e

#SBATCH -J stop
#SBATCH -A DSMITH-BIOCLOUD
#SBATCH -o slurm-%A.out
#SBATCH -p biocloud-normal
#SBATCH --time=5:00:00

srun -n 1 stop.sh
