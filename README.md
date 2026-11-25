# Snakemake workflow: `map-pipeline`

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)

A Snakemake workflow for mapping sequencing reads from modern or contemporary samples.

This pipeline can take either:
* standard paired-end reads;
* historical paired-end reads that have already been merged using e.g. [nf-polish](https://github.com/MozesBlom/nf-polish)

---

- [Snakemake workflow: `map-pipeline`](#map-pipeline)
  - [Workflow](#workflow)
  - [Setup](#setup)
  - [Configuration](#configuration)
  - [References](#references)

## Workflow

Main steps are outlined below:
1. [OPIONAL] Trim reads and remove adapters using [fastp](https://github.com/OpenGene/fastp)
2. Map reads to a reference genome using [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
3. Deduplication of merged paired end reads using either [PicardMarkDuplicates](https://broadinstitute.github.io/picard/) (modern samples) or [DeDup](https://github.com/apeltzer/DeDup) (historical samples)
4. Calculate mapping stats and depth using [Samtools](https://github.com/samtools/samtools)
5. [OPTIONAL] Assess DNA damage and using [MapDamage2](https://github.com/ginolhac/mapDamage) (historical samples only)

---

## Setup

You will need a conda distribution installed on your machine prior to installation.

Install the pipeline using:

`git clone https://github.com/abbyevewilliams/map-pipeline.git`

Then, use conda to install the environment from the `environment.yaml` provided.

`conda create --prefix ./snakemake-env --file environment.yaml`

## Configuration

Before running:
- configure the pipeline by editing `config/config.yaml`
- add any appropriate HPC profiles in `profiles/`
- if using a slurm-based cluster - edit the `run.sh` as necessary.

You should configure the following options in the `config/config.yaml`:

* `reference_genome`: path to your reference genome
* `samples`: the path to your samples.txt file. This should contain the following information in tab separated format: sample_id, flowcell, lane, path to read 1, path to read 2, path to merged reads. If any fields do not apply (e.g. because there are only paired end reads and no merged reads) they can be left blank. See `TEMPLATE_samples.tsv`
* `trim_reads`: [True/False] whether to run fastp with to trim and remove adapters. Settings can be edited in the `workflow/rules/03_map.smk`
* `dedup_method`: ["picard" or "dedup"] whether to run PicardMarkDuplicates or DeDup for duplicate removal. Picard is favoured for modern samples whereas DeDup is favoured for historical samples (Irestedt et al 2022)
* `remove_duplicates_picard`: [true/false] whether to remove duplicates (rather than just marking them) with picard
* `mapdamage_rescale`: [True/False] whether to use Mapdamage2 to rescale base qualities (historical samples only)
* `fastp`: set parameters for trimming with fastp, if using.

## References

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. _Sustainable data analysis with Snakemake_. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.

---

This pipeline was built in [snakemake](https://snakemake.github.io/) using [this workflow template](https://github.com/snakemake-workflows/snakemake-workflow-template).
