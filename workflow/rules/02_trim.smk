# Run fastp

if config["trim_reads"]:
    rule fastp:
        input:
            sample=lambda wc: [
            get_fastq(wc.sample, wc.flowcell, wc.lane, "1"),
            get_fastq(wc.sample, wc.flowcell, wc.lane, "2")
        ]
        output:
            trimmed=["results/trimmed/{sample}/{flowcell}_{lane}_1.fastq.gz", "results/trimmed/{sample}/{flowcell}_{lane}_2.fastq.gz"],
            html="results/trimmed/{sample}/{flowcell}_{lane}.html",
            json="results/trimmed/{sample}/{flowcell}_{lane}.json"
        params:
            extra=config["fastp"]["extra"]
        log:
            "results/logs/fastp/{sample}_{flowcell}_{lane}.log"
        threads: 4
        wrapper:
            "v3.3.3/bio/fastp"