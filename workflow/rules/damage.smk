
# Run mapdamage2

rule mapdamage2:
    input:
        ref=config["data"]["reference-genome"],
        bam="dedup/{sample}.bam",
    output:
        log="mapdamage/{sample}/Runtime_log.txt",  # output folder is infered from this file, so it needs to be the same folder for all output files
        GtoA3p="mapdamage/{sample}/3pGtoA_freq.txt",
        CtoT5p="mapdamage/{sample}/5pCtoT_freq.txt",
        dnacomp="mapdamage/{sample}/dnacomp.txt",
        frag_misincorp="mapdamage/{sample}/Fragmisincorporation_plot.pdf",
        len="mapdamage/{sample}/Length_plot.pdf",
        lg_dist="mapdamage/{sample}/lgdistribution.txt",
        misincorp="mapdamage/{sample}/misincorporation.txt",
        rescaled_bam="mapdamage/{sample}.rescaled.bam" # uncomment if you want the rescaled BAM file
    params:
        extra="--no-stats",  # optional parameters for mapdamage2 (except -i, -r, -d, --rescale)
    log:
        "logs/mapdamage/{sample}.log"
    wrapper:
        "v5.8.0/bio/mapdamage2"