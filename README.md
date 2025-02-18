# A snakemake pipeline for the Norfolk Island Zosterops project
*Abby Williams, University of Oxford, 2025*

**THIS PIPELINE IS A WORK IN PROGRESS**

A pipeline for cleaning raw Illumina sequencing reads from avian museum samples and mapping them to the *Zosterops lateralis* pseudochromosome assembly.

Specific steps are outlined below:
1. Initial quality check with FastQC
2. Adapter removal and merging of paired-end reads with AdapterRemoval2
3. Second quality check with FastQC
4. Mapping of reads to the *Zosterops lateralis* pseudochrome assembly using BWA-MEM
5. Deduplication using PicardMarkDuplicates
6. Calculation of mapping stats and depth using Samtools
7. Assessment of DNA damage using MapDamage2

This pipeline was built in [snakemake](https://snakemake.github.io/) using this [workflow template](https://github.com/snakemake-workflows/snakemake-workflow-template).
