# A snakemake pipeline for the Norfolk Island Zosterops project
*Abby Williams, University of Oxford, 2025*

A pipeline for cleaned sequencing reads from avian museum samples to the *Zosterops lateralis* pseudochromosome assembly. 
This pipeline is specialised to work with merged, paired-end reads that have already been cleaned using e.g. [nf-polish](https://github.com/MozesBlom/nf-polish).

---

**Workflow**

Main steps are outlined below:
1. Map reads to the *Zosterops lateralis* pseudochrome assembly using [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
2. Deduplication of merged paired end reads using [DeDup](https://github.com/apeltzer/DeDup)
3. Calculate mapping stats and depth using [Samtools](https://github.com/samtools/samtools)
4. Assess DNA damage using [MapDamage2](https://github.com/ginolhac/mapDamage)

---

**Installation and usage**

Use conda/mamba to install the environment from the `environment.yaml` provided.

`conda create --prefix ./snakemake-env --file environment.yaml`

Do the following prior to running: 
- edit file paths in `config/config.yaml`
- add any appropriate profiles in `profiles/`
- edit the `run.sh` depending on your HPC environment

Then run as appropriate for your HPC. For slurm-based schedulers, run:

`sbatch run.sh`

---

This pipeline was built in [snakemake](https://snakemake.github.io/) using [this workflow template](https://github.com/snakemake-workflows/snakemake-workflow-template).
