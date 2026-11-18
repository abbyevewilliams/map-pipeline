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
        "v7.2.0/bio/bwa-mem2/index"

# Map reads to reference

# Paired end reads (if present)

rule bwa_mem2_pe:
        input:
            reads=lambda wc: [
                f"results/trimmed/{wc.sample}/{wc.flowcell}_{wc.lane}_1.fastq.gz",
                f"results/trimmed/{wc.sample}/{wc.flowcell}_{wc.lane}_2.fastq.gz"
                ] if TRIM_READS else [
                    get_fastq(wc.sample, wc.flowcell, wc.lane, "1"),
                    get_fastq(wc.sample, wc.flowcell, wc.lane, "2")
                ],
            idx=multiext(config["reference_genome"], ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123")
        output:
            "results/mapped/{sample}/{flowcell}_{lane}_paired.bam"
        log:
            "results/logs/bwa_mem2_pe/{sample}/{flowcell}_{lane}.log"
        params:
            sort="samtools",
            extra=lambda wc: (
                f"-R '@RG\\tID:{wc.sample}.{wc.flowcell}.{wc.lane}.PE"
                f"\\tSM:{wc.sample}"
                f"\\tPL:ILLUMINA"
                f"\\tLB:{wc.sample}_lib1"
                f"\\tPU:{wc.flowcell}.{wc.lane}'"
            )
        wrapper:
            "v9.19.5/bio/bwa-mem2/mem"

# Merged reads (if present)

rule bwa_mem2_merged:
        input:
            reads=lambda wc: (f"results/trimmed/{wc.sample}/{wc.flowcell}_{wc.lane}_U.fastq.gz" 
                if TRIM_READS else 
                get_fastq(wc.sample, wc.flowcell, wc.lane, "U")),
            idx=multiext(config["reference_genome"], ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123")
        output:
            "results/mapped/{sample}/{flowcell}_{lane}_U.bam"
        log:
            "results/logs/bwa_mem2_merged/{sample}/{flowcell}_{lane}.log"
        params:
            sort="samtools",
            extra=lambda wc: (
                f"-R '@RG\\tID:{wc.sample}.{wc.flowcell}.{wc.lane}.merged"
                f"\\tSM:{wc.sample}"
                f"\\tPL:ILLUMINA"
                f"\\tLB:{wc.sample}_lib1"
                f"\\tPU:{wc.flowcell}.{wc.lane}'"
            )
        wrapper:
            "v9.19.5/bio/bwa-mem2/mem"

# Helper function for finding all BAMs associated with a particular sample

def get_dedup_input(wc):

    rows = samples.loc[
        samples["sample_id"] == wc.sample
    ]

    bams = []

    for row in rows.itertuples():

        prefix = (
            f"results/mapped/{wc.sample}/{row.flowcell}_{row.lane}"
        )

        if row.read1 and row.read2:
            bams.append(f"{prefix}_paired.bam")

        if row.readU:
            bams.append(f"{prefix}_U.bam")

    return bams