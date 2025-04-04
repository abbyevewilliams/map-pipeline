# A snakemake pipeline for the Norfolk Island Zosterops project
*Abby Williams, University of Oxford, 2025*

A pipeline for cleaned sequencing reads from avian museum samples to the *Zosterops lateralis* pseudochromosome assembly. 
This pipeline is specialised to work with merged, paired-end reads that have already been cleaned using e.g. [nf-polish](https://github.com/MozesBlom/nf-polish).

---

**Workflow**

Main steps are outlined below:
1. [OPIONAL] Trim reads and remove adapters using [fastp](https://github.com/OpenGene/fastp)
2. Map reads to the *Zosterops lateralis* pseudochrome assembly using [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
3. Deduplication of merged paired end reads using [DeDup](https://github.com/apeltzer/DeDup) (museum samples) or [PicardMarkDuplicates](https://broadinstitute.github.io/picard/) (contemporary samples)
4. Calculate mapping stats and depth using [Samtools](https://github.com/samtools/samtools)
5. Assess DNA damage using [MapDamage2](https://github.com/ginolhac/mapDamage) (museum samples only)

---

**Installation and usage**

Use conda/mamba to install the environment from the `environment.yaml` provided.

`mamba create --prefix ./snakemake-env --file environment.yaml`

Do the following prior to running: 
- configure the pipeline by editing `config/config.yaml`
- add any appropriate profiles in `profiles/`
- edit the `run.sh` depending on your HPC environment

Then run as appropriate for your HPC. For slurm-based schedulers, run:

`sbatch run.sh`

---

This pipeline was built in [snakemake](https://snakemake.github.io/) using [this workflow template](https://github.com/snakemake-workflows/snakemake-workflow-template).
