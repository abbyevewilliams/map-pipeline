# A snakemake pipeline for the Norfolk Island Zosterops project
*Abby Williams, University of Oxford, 2025*

A pipeline for mapping raw Illumina sequencing reads from avian museum samples to the *Zosterops lateralis* pseudochromosome assembly.

Specific steps are outlined below:
1. Index the genome using BWA-MEM2
2. Map reads to the *Zosterops lateralis* pseudochrome assembly using BWA-MEM2
3. Deduplication using PicardMarkDuplicates
4. Calculate mapping stats and depth using Samtools
5. Assess DNA damage using MapDamage2

**Installation and usage**

Use conda/mamba to install the environment from the `environment.yaml` provided.

`conda create --prefix ./snakemake-env --file environment.yaml`

You should also edit the file paths in `config/config.yaml` and add any appropriate profiles in `profiles/` before running snakemake.

---

This pipeline was built in [snakemake](https://snakemake.github.io/) using this [workflow template](https://github.com/snakemake-workflows/snakemake-workflow-template).
