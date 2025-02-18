# Initial fastqc

rule fastqc_initial:
    input:
        fq=lambda wildcards: os.path.join(config["data"]["reads_dir"], f"{wildcards.sample}_R{wildcards.read}.fastq.gz")
    output:
        html="fastqc_initial/{sample}_R{read}_fastqc.html",
        zip="fastqc_initial/{sample}_R{read}_fastqc.zip"
    log:
        "logs/fastqc_initial/{sample}_R{read}.log"
    wrapper:
        "v5.8.0/bio/fastqc"

# Remove adapters and merge

rule adapterremoval:
    input:
        R1=lambda wildcards: os.path.join(config["data"]["reads_dir"], f"{wildcards.sample}_R1.fastq.gz"),
        R2=lambda wildcards: os.path.join(config["data"]["reads_dir"], f"{wildcards.sample}_R2.fastq.gz")
    output:
        fq1="trimmed/{sample}_R1.fastq.gz",                            # trimmed mate1 reads
        fq2="trimmed/{sample}_R2.fastq.gz",                            # trimmed mate2 reads
        collapsed="trimmed/{sample}.collapsed.fastq.gz",               # overlapping mate-pairs which have been merged into a single read
        collapsed_trunc="trimmed/{sample}.collapsed.trimmed.fastq.gz", # collapsed reads that were quality trimmed
        settings="trimmed/{sample}.settings"                           # parameters as well as overall statistics
    log:
        "logs/adapterremoval/{sample}.log"
    params:
        adapter1=config["data"]["adapter1"], 
        adapter2=config["data"]["adapter2"],
        extra="--collapse --collapse-deterministic --trimns --trimqualities"
    wrapper:
        "v5.8.0/bio/adapterremoval"

rule fastqc_post_trim:
    input:
        "trimmed/{sample}.collapsed.trimmed.fastq.gz"
    output:
        html="fastqc_post_trim/{sample}_collapsed_fastqc.html",
        zip="fastqc_post_trim/{sample}_collapsed_fastqc.zip"
    log:
        "logs/fastqc_post_trim/{sample}.log"
    wrapper:
        "v5.8.0/bio/fastqc"