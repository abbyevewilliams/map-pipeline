# Run fastqc, using our own naming convention
rule fastqc:
    input:
        lambda wc: (
            get_fastq(wc.sample, wc.flowcell, wc.lane, wc.read)
            if wc.stage == "pre_trim"
            else f"results/trimmed/{wc.sample}/{wc.flowcell}_{wc.lane}_{wc.read}.fastq.gz"
        )
    output:
        html="results/fastqc_{stage}/{sample}/{flowcell}_{lane}_{read}.html",
        zip="results/fastqc_{stage}/{sample}/{flowcell}_{lane}_{read}.zip"
    conda:
        "../../envs/fastqc.yaml"
    log:
        "results/logs/fastqc_{stage}/{sample}/{flowcell}_{lane}_{read}.log"
    # Create staging directory to initially generate files, then rename how we like
    params:
        staging_dir=lambda wc: (
        f"results/fastqc_{wc.stage}/{wc.sample}/"
        f"{wc.flowcell}_{wc.lane}_{wc.read}.staging"
    )
    # Run command and rename files, then delete originals
    shell:
        r"""
        mkdir -p {params.staging_dir:q}
        mkdir -p "$(dirname {output.html:q})"

        fastqc \
            --outdir {params.staging_dir:q} \
            {input:q} \
            > {log:q} 2>&1

        # Derive the output basename from the input FASTQ
        filename=$(basename {input:q})
        filename=${{filename%.gz}}

        # Strip .fastq or .fq endings
        filename=${{filename%.fastq}}
        filename=${{filename%.fq}}
        
        # Move FastQC outputs to Snakemake's expected paths
        mv "{params.staging_dir}/${{filename}}_fastqc.html" {output.html:q}
        mv "{params.staging_dir}/${{filename}}_fastqc.zip" {output.zip:q}

        rmdir {params.staging_dir:q}
        """