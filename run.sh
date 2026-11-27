#!/bin/bash
#SBATCH --job-name=map-pipeline
#SBATCH --partition=short
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --output=slurm_%j.log
#SBATCH --error=slurm_%j.error

# Load necessary modules
ml Anaconda3

# Load environment with snakemake (and some other things)
source activate ./snakemake-env

# Run the pipeline
snakemake --unlock
snakemake --workflow-profile profiles/slurm \
	--use-conda -j 200
