# Index reference
rule bwa_index:
    input:
        ref=config["reference_genome"]
    output:
        multiext(config["reference_genome"], ".0123", ".amb", ".ann", ".bwt.2bit.64", ".pac")
    log:
        "results/logs/bwa_index/index.log"
    threads: 4
    resources:
        mem="32GB"
    wrapper:
        "v5.8.2/bio/bwa-mem2/index"

# Map merged reads to reference
rule bwa_map:
    input:
        reads=lambda wildcards: os.path.join(config["clean_reads_dir"], wildcards.sample, f"{wildcards.sample}_U.fastq.gz"),
        idx=multiext(config["reference_genome"], ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123")
    output:
        "results/mapped/{sample}.bam"
    log:
        "results/logs/bwa_map/{sample}.log"
    threads: 8
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/bwa-mem2/mem"

# Sort reads
rule samtools_sort:
    input:
        "results/mapped/{sample}.bam"
    output:
        "results/sorted/{sample}.bam"
    log:
        "results/logs/samtools_sort/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/sort"

# Index the sorted bam file
rule samtools_index:
    input:
        "results/sorted/{sample}.bam"
    output:
        "results/sorted/{sample}.bam.bai"
    log:
        "results/logs/samtools_index/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/index"

# Mark duplicates
rule markduplicates_bam:
    input:
        "results/sorted/{sample}.bam"
    output:
        "results/dedup/{sample}.bam",
        "results/dedup/{sample}.metrics.txt"
    log:
        "results/logs/markduplicates/{sample}.log"
    params:
        extra="--REMOVE_DUPLICATES true"
    threads: 4
    wrapper:
        "v5.8.0/bio/picard/markduplicates"

# Calculate depth
rule samtools_depth:
    input:
        "results/dedup/{sample}.bam"
    output:
        "results/dedup/{sample}.depth"
    log:
        "results/logs/samtools_depth/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/depth"

# Calculate stats
rule samtools_stats:
    input:
        "results/dedup/{sample}.bam"
    output:
        "results/dedup/{sample}.stats"
    log:
        "results/logs/samtools_stats/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/stats"