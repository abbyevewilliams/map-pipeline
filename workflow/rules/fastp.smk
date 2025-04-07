if config["run_fastp"]:
    rule fastp:
        input:
            sample=lambda wildcards: [
                os.path.join(config["reads_dir"], f"{wildcards.sample}_1.fastq.gz"),
                os.path.join(config["reads_dir"], f"{wildcards.sample}_2.fastq.gz")
            ]
        output:
            trimmed=["results/fastp/{sample}_1.fastq.gz", "results/fastp/{sample}_2.fastq.gz"],
            html="results/fastp/{sample}_1.html",
            json="results/fastp/{sample}_1.json",
        log:
            "results/logs/fastp/{sample}.log"
        threads: 4
        wrapper:
            "v5.10.0/bio/fastp"

# Run fastqc again
rule fastqc_post_trim:
    input:
        lambda wildcards: os.path.join("results/fastp", f"{wildcards.sample}_{wildcards.read}.fastq.gz"),
    output:
        html="results/fastqc_post_trim/{sample}_{read}.html",
        zip="results/fastqc_post_trim/{sample}_{read}.zip"
    params:
        extra = "--quiet"
    log:
        "results/logs/fastqc_post_trim/{sample}_{read}.log"
    threads: 1
    resources:
        mem_mb = 1024
    wrapper:
        "v5.10.0/bio/fastqc"