
# Calculate depth
rule samtools_average_depth:
    input:
        bam="results/dedup/{sample}.bam"
    output:
        "results/depth/{sample}.txt"
    threads: 1
    shell:
        r"""
        samtools depth -a {input.bam:q} |
            awk '{{sum+=$3; n++}} END {{if(n) print sum/n; else print 0}}' \
            > {output:q}
        """

# Calculate average depth for each sample
rule summarise_average_depth:
    input:
        depth_files=expand("results/depth/{sample}.txt", sample=SAMPLES)
    output:
        "results/average_depth.txt"
    shell:
        r"""
        printf "Sample\tAverage_Depth\n" > {output:q}

        for depth_file in {input.depth_files:q}; do
            sample=$(basename "$depth_file" .txt)
            depth=$(cat "$depth_file")
            printf "%s\t%s\n" "$sample" "$depth" >> {output:q}
        done
        """

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
        "v9.19.5/bio/samtools/stats"

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