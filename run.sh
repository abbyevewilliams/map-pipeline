#!/bin/bash
#SBATCH --job-name=smk_pipeline
#SBATCH --partition=short
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=logs/sbatch_%j.log
#SBATCH --error=logs/sbatch_%j.error

# Load necessary modules
ml Mamba/23.11.0-0

# Load environment with snakemake and new conda installed
source activate /data/biol-silvereye/ball6625/norfolk-pipeline/snakemake-env
conda config --set channel_priority strict

# Run the pipeline
#snakemake --unlock
snakemake --workflow-profile profiles/slurm \
	 --use-conda --keep-going \
	--rerun-incomplete -j 10
