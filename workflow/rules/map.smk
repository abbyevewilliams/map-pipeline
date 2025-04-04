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

RUN_FASTP=config["run_fastp"]
if RUN_FASTP:
    reads_dir="results/fastp"
else:
    reads_dir=config["reads_dir"]

# Map merged reads to reference
rule bwa_map:
    input:
        read1=lambda wildcards: os.path.join(reads_dir, f"{wildcards.sample}_1.fastq.gz"),
        read2=lambda wildcards: os.path.join(reads_dir, f"{wildcards.sample}_2.fastq.gz"),
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

# Remove duplicates

USE_PICARD = config["dedup_with_picard"]

if USE_PICARD:
    rule markduplicates_bam:
            input:
                bams="results/sorted/{sample}.bam"
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
else:
    rule dedup:
        input:
            bam="results/sorted/{sample}.bam"
        output:
            bam=temp("results/dedup/{sample}.bam")
        conda: 
            "../../envs/dedup.yaml"
        log:
            "results/logs/dedup/{sample}.log"
        resources:
            mem="100GB"
        shell:
            """
            export _JAVA_OPTIONS="-Xmx90G"
            bam={output.bam}
            mkdir -p $(dirname $bam)
            dedup -i {input.bam} -m -o $(dirname $bam);
            mv ${{bam%%.bam}}_rmdup.bam $bam

            """

# Sort deduped bam file
rule samtools_sort_dedup:
    input:
        "results/dedup/{sample}.bam",
    output:
        "results/dedup/{sample}.sorted.bam",
    log:
        "results/logs/samtools_sort_dedup/{sample}.log",
    threads: 8
    resources:
        mem="8GB"
    wrapper:
        "v5.8.3/bio/samtools/sort"

# Index deduped bam file
rule samtools_index_dedup:
    input:
        "results/dedup/{sample}.sorted.bam"
    output:
        "results/dedup/{sample}.sorted.bam.bai"
    log:
        "results/logs/samtools_index_dedup/{sample}.log"
    resources:
        mem="8GB"
    wrapper:
        "v5.8.0/bio/samtools/index"

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
    priority: 100
    shell:
        """
        echo -e "Sample\tAverage_Depth" > {output}
        for depth_file in {input.depth_files}; do
            sample=$(basename "$depth_file" .depth)
            avg_depth=$(awk '{{sum+=$3}} END {{if (NR>0) print sum/NR; else print 0}}' "$depth_file")
            echo -e "$sample\t$avg_depth" >> {output}
        done
        """