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

# Function to get the correct reads based on sample and lane

def get_reads(sample, lane):
    # Use glob to find the files matching the pattern
    read_1 = glob.glob(f"{config['clean_reads_dir']}/{sample}/{sample}_{lane}_1.fq.gz")
    read_2 = glob.glob(f"{config['clean_reads_dir']}/{sample}/{sample}_{lane}_2.fq.gz")
    
    # Return the list of matched files
    return read_1 + read_2  # Combine R1 and R2 files

# Mapping
rule bwa_map:
    input:
        reads=lambda wildcards: get_reads(wildcards.sample, wildcards.lane),
        idx=multiext(config["reference_genome"], ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123")
    output:
        "results/mapped/{sample}--{lane}.bam"
    params:
        rg="@RG\tID:{lane}\tSM:{sample}\tLB:{sample}_lib\tPL:ILLUMINA\tPU:{lane}"
    log:
        "results/logs/bwa_map/{sample}--{lane}.log"
    threads: 8
    resources:
        mem="32GB"
    wrapper:
        "v5.8.0/bio/bwa-mem2/mem"

# Sort reads
rule samtools_sort:
    input:
        "results/mapped/{sample}--{lane}.bam"
    output:
        "results/sorted/{sample}--{lane}.bam"
    log:
        "results/logs/samtools_sort/{sample}--{lane}.log"
    threads: 4
    resources:
        mem="100GB"
    wrapper:
        "v5.8.0/bio/samtools/sort"

# Index the sorted bam file
rule samtools_index:
    input:
        "results/sorted/{sample}--{lane}.bam"
    output:
        "results/sorted/{sample}--{lane}.bam.bai"
    log:
        "results/logs/samtools_index/{sample}--{lane}.log"
    resources:
        mem="8GB"
    wrapper:
        "v5.8.0/bio/samtools/index"

# Merge bams from different lanes
def get_bams_to_merge(wildcards):
    """Finds all BAM files to merge for a given sample by identifying its lanes."""
    lanes = get_lanes(wildcards.sample)
    return [f"results/sorted/{wildcards.sample}--{lane}.bam" for lane in lanes]

rule samtools_merge:
    input:
        get_bams_to_merge
    output:
        "results/merged/{sample}.bam"
    log:
        "results/logs/samtools_merge/{sample}.log"
    threads: 8
    resources:
        mem="32GB"
    wrapper:
        "v5.8.2/bio/samtools/merge"

# Mark duplicates
rule markduplicates_bam:
    input:
        bams="results/merged/{sample}.bam"
    output:
        bam="results/dedup/{sample}.bam",
        metrics="results/dedup/{sample}.metrics.txt"
    log:
        "results/logs/markduplicates/{sample}.log"
    params:
        extra="--REMOVE_DUPLICATES true"
    threads: 4
    resources:
        mem="64GB"
    wrapper:
        "v5.8.0/bio/picard/markduplicates"

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