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
        "results/sorted/{sample}.bam"
    log:
        "results/logs/bwa_map/{sample}.log"
    params:
        sort="samtools"
    threads: 8
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/bwa-mem2/mem"

# Index the sorted bam file
rule samtools_index:
    input:
        "results/sorted/{sample}.bam"
    output:
        "results/sorted/{sample}.bam.bai"
    log:
        "results/logs/samtools_index/{sample}.log"
    resources:
        mem="8GB"
    wrapper:
        "v5.8.0/bio/samtools/index"

# Mark duplicates
rule dedup:
    input:
        bam="results/sorted/{sample}.bam",
        bai="results/sorted/{sample}.bam.bai"
    output:
        dedup_bam="results/dedup/{sample}.bam",
        log="logs/dedup/{sample}.log"
    conda:
        "/data/biol-silvereye/ball6625/map-pipeline/envs/dedup.yaml"
    shell:
        """
        DeDup -i {input.bam} -o {output.dedup_bam} -m

        """

# Calculate depth
rule samtools_depth:
    input:
        bams="results/dedup/{sample}.bam"
    output:
        "results/dedup/{sample}.depth"
    log:
        "results/logs/samtools_depth/{sample}.log"
    threads: 4
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/samtools/depth"

# Calculate stats
rule samtools_stats:
    input:
        bam="results/dedup/{sample}.bam"
    output:
        "results/dedup/{sample}.stats"
    log:
        "results/logs/samtools_stats/{sample}.log"
    threads: 4
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/samtools/stats"

#Summarise key stats across all samples
rule summarise_samtools_stats:
    input:
        stats_files=expand("results/dedup/{sample}.stats", sample=SAMPLES)
    output:
        "results/mapping_summary.txt"
    shell:
        """
        echo -e "Sample\tTotal_Reads\tMapped_Reads\tPercent_Mapped\tError_Rate\tAvg_Quality" > {output}
        for stats_file in {input.stats_files}; do
            sample=$(basename "$stats_file" .stats)
            total_reads=$(grep "raw total sequences:" "$stats_file" | cut -f 3)
            mapped_reads=$(grep "reads mapped:" "$stats_file" | head -n 1 | cut -f 3)
            error_rate=$(grep "error rate:" "$stats_file" | cut -f 3)
            avg_quality=$(grep "average quality:" "$stats_file" | cut -f 3)
            percent_mapped=$(awk -v mapped="$mapped_reads" -v total="$total_reads" 'BEGIN {{ if (total>0) print (mapped/total)*100; else print 0 }}')
            echo -e "$sample\t$total_reads\t$mapped_reads\t$percent_mapped\t$error_rate\t$avg_quality" >> {output}
        done
        """

# Calculate average depth for each sample
rule compute_average_depth:
    input:
        depth_files=expand("results/dedup/{sample}.depth", sample=SAMPLES)
    output:
        "results/avg_depth.txt"
    shell:
        """
        echo -e "Sample\tAverage_Depth" > {output}
        for depth_file in {input.depth_files}; do
            sample=$(basename "$depth_file" .depth)
            avg_depth=$(awk '{{sum+=$3}} END {{if (NR>0) print sum/NR; else print 0}}' "$depth_file")
            echo -e "$sample\t$avg_depth" >> {output}
        done
        """