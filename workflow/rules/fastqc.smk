# Run fastqc
rule fastqc:
    input:
        lambda wildcards: os.path.join(config["reads_dir"], f"{wildcards.sample}_{wildcards.read}.fastq.gz"),
    output:
        html="results/fastqc/{sample}_{read}.html"
    params:
        extra = "--quiet"
    log:
        "results/logs/fastqc/{sample}_{read}.log"
    threads: 1
    resources:
        mem_mb = 1024
    wrapper:
        "v5.10.0/bio/fastqc"