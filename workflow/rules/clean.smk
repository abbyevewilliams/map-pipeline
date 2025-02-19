# Initial fastqc

rule fastqc_initial:
    input:
        fq=lambda wildcards: os.path.join(config["reads_dir"], f"{wildcards.sample}_R{wildcards.read}.fastq.gz")
    output:
        html="results/fastqc_initial/{sample}_R{read}_fastqc.html",
        zip="results/fastqc_initial/{sample}_R{read}_fastqc.zip"
    log:
        "results/logs/fastqc_initial/{sample}_R{read}.log"
    wrapper:
        "v5.8.0/bio/fastqc"

# Remove adapters and merge

rule adapterremoval:
    input:
        sample=lambda wildcards: [
            os.path.join(config["reads_dir"], f"{wildcards.sample}_R1.fastq.gz"),
            os.path.join(config["reads_dir"], f"{wildcards.sample}_R2.fastq.gz"),
        ]
    output:
        fq1="results/trimmed/{sample}_R1.fastq.gz",                            # trimmed mate1 reads
        fq2="results/trimmed/{sample}_R2.fastq.gz",                            # trimmed mate2 reads
        collapsed="results/trimmed/{sample}.collapsed.fastq.gz",               # overlapping mate-pairs which have been merged into a single read
        collapsed_trunc="results/trimmed/{sample}.collapsed.trimmed.fastq.gz", # collapsed reads that were quality trimmed
        singleton="results/trimmed/{sample}.singleton.fastq.gz",               # mate-pairs for which the mate has been discarded
        discarded="results/trimmed/{sample}.discarded.fastq.gz",               # reads that did not pass filters
        settings="results/trimmed/{sample}.settings"                           # parameters as well as overall statistics
    log:
        "results/logs/adapterremoval/{sample}.log"
    params:
        adapter1=config["adapter1"], 
        adapter2=config["adapter2"],
        extra="--collapse --collapse-deterministic --trimns --trimqualities"
    wrapper:
        "v5.8.0/bio/adapterremoval"

# Run fastqc again

rule fastqc_post_trim:
    input:
        "results/trimmed/{sample}.collapsed.trimmed.fastq.gz"
    output:
        html="results/fastqc_post_trim/{sample}_collapsed_fastqc.html",
        zip="results/fastqc_post_trim/{sample}_collapsed_fastqc.zip"
    log:
        "results/logs/fastqc_post_trim/{sample}.log"
    wrapper:
        "v5.8.0/bio/fastqc"