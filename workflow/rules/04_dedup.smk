# Get dedup method

USE_PICARD = config["dedup_method"]=="picard"
USE_DEDUP = config["dedup_method"]=="dedup"

if not (USE_PICARD or USE_DEDUP):
    raise ValueError(
            f"Expected either 'picard' or 'dedup'"
    )

if USE_PICARD:
    rule markduplicates_bam:
            input:
                bams=get_dedup_input
            output:
                bam="results/dedup/{sample}.bam",
                metrics="results/dedup/{sample}.metrics.txt",
                idx="results/dedup/{sample}.bam.bai",
            log:
                "results/logs/markduplicates/{sample}.log",
            params:
                extra=f"--REMOVE_DUPLICATES {str(config['remove_duplicates_picard']).lower()} --CREATE_INDEX true"
            threads: 4
            resources:
                mem="64GB"
            wrapper:
                "v9.19.5/bio/picard/markduplicates"

if USE_DEDUP:
    rule dedup:
        input:
            bam=get_dedup_input
        output:
            bam="results/dedup/{sample}.bam"
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
    rule samtools_index:
        input:
            "results/dedup/{sample}.bam"
        output:
            "results/dedup/{sample}.bam.bai"
        log:
            "logs/samtools_index/{sample}.log",
        wrapper:
            "v9.19.5/bio/samtools/index"
