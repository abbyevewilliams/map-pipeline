# Map reads to the reference
rule bwa_map:
    input:
        ref=config["data"]["reference-genome"],
        fq1="trimmed/{sample}.collapsed.trimmed.fastq.gz",  # Adjust to the desired output from adapterremoval
        fq2="trimmed/{sample}.collapsed.trimmed.fastq.gz"   # Same file used for both paired-end (collapsed reads)
    output:
        "mapped/{sample}.bam"
    log:
        "logs/bwa-map/{sample}.log"
    threads: 8
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/bwa/mem"

# Sort reads
rule samtools_sort:
    input:
        "mapped/{sample}.bam"
    output:
        "sorted/{sample}.bam"
    log:
        "logs/samtools_sort/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/sort"

# Index the sorted bam file
rule samtools_index:
    input:
        "sorted/{sample}.bam"
    output:
        "sorted/{sample}.bam.bai"
    log:
        "logs/samtools_index/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/index"

# Mark duplicates
rule markduplicates_bam:
    input:
        "sorted/{sample}.bam"
    output:
        "dedup/{sample}.bam",
        "dedup/{sample}.metrics.txt"
    log:
        "logs/markduplicates/{sample}.log"
    params:
        extra="--REMOVE_DUPLICATES true"
    threads: 4
    wrapper:
        "v5.8.0/bio/picard/markduplicates"

# Calculate depth
rule samtools_depth:
    input:
        "dedup/{sample}.bam"
    output:
        "dedup/{sample}.depth"
    log:
        "logs/samtools_depth/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/depth"

# Calculate stats
rule samtools_stats:
    input:
        "dedup/{sample}.bam"
    output:
        "dedup/{sample}.stats"
    log:
        "logs/samtools_stats/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/stats"