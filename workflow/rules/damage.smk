
# Run mapdamage2

rule mapdamage2:
    input:
        ref=config["reference-genome"],
        bam="results/dedup/{sample}.bam",
    output:
        log="results/mapdamage/{sample}/Runtime_log.txt",  # output folder is infered from this file, so it needs to be the same folder for all output files
        GtoA3p="results/mapdamage/{sample}/3pGtoA_freq.txt",
        CtoT5p="results/mapdamage/{sample}/5pCtoT_freq.txt",
        dnacomp="results/mapdamage/{sample}/dnacomp.txt",
        frag_misincorp="results/mapdamage/{sample}/Fragmisincorporation_plot.pdf",
        len="results/mapdamage/{sample}/Length_plot.pdf",
        lg_dist="results/mapdamage/{sample}/lgdistribution.txt",
        misincorp="results/mapdamage/{sample}/misincorporation.txt",
        rescaled_bam="results/mapdamage/{sample}.rescaled.bam" # uncomment if you want the rescaled BAM file
    log:
        "results/logs/mapdamage/{sample}.log"
    wrapper:
        "v5.8.0/bio/mapdamage2"