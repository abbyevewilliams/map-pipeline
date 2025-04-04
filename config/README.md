# Configuring the workflow

You should configure the following options in the config/config.yaml:

* `reads_dir`: the absolute path to your raw reads.
* `samples`: the path to your samples.txt file. This should contain the base names of your samples, e.g. if you have reads sample1_1.fastq.gz and sample1_2.fastq.gz then you should add sample1 to the samples.txt (see template provided).
* `reference_genome`: path to your reference genome.
* `run_fastp`: [True/False] whether to run fastp with default settings to trim and remove adapters. You may choose to disable this if you have already cleaned your reads using a custom pipeline, or if you prefer to do QC after mapping.
* `dedup_with_picard`: [True/False] whether to use PicardMarkDuplicates for duplicate removal. If using merged reads (a common output of ancient/historical DNA cleaning pipelines) you should disable this option, and DeDup will be used instead.
* `mapdamage_rescale`: [True/False] whether to use Mapdamage2 to rescale base qualities. Set to true for historical samples.
