if config["run_fastp"]:
    rule fastp:
        input:
            lambda wildcards: os.path.join(config["reads_dir"], f"{wildcards.sample}_{wildcards.read}.fastq.gz")
        output:
            trimmed="results/fastp/{sample}_{read}.fastq.gz",
            html="results/fastp/{sample}_{read}.html"
        log:
            "results/logs/fastp/{sample}_{read}.log"
        threads: 4
        wrapper:
            "v5.10.0/bio/fastp"