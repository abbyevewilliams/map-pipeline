# ==============================================================================
#     Setup
# ==============================================================================

# Packages
import pandas as pd
import os
print(sys.version)

# ==============================================================================
#     Load options from config
# ==============================================================================

TRIM_READS=config["trim_reads"]
MAPDAMAGE_RESCALE=config["mapdamage_rescale"]

# ==============================================================================
#     Reading in the data
# ==============================================================================

# Load sample metadata
samples = pd.read_csv(
    config["samples"],
    sep="\t",
    dtype=str,
    keep_default_na=False
)

# Create list of samples
SAMPLES = samples["sample_id"].unique().tolist()

# List of sample types
SAMPLE_TYPES = (
    samples.drop_duplicates("sample_id")
    .set_index("sample_id")["sample_type"]
    .to_dict()
)

# Separate out contemporary and historical samples
CONTEMPORARY_SAMPLES = (
    samples.loc[
        samples["sample_type"] == "contemporary",
        "sample_id"
    ]
    .unique()
    .tolist()
)

HISTORICAL_SAMPLES = (
    samples.loc[
        samples["sample_type"] == "historical",
        "sample_id"
    ]
    .unique()
    .tolist()
)

# ==============================================================================
#     Helper functions
# ==============================================================================

#Function to get initial .fastq.gz names

def get_fastq(sample, flowcell, lane, read):

    # Find the matching row in the sample sheet
    match = samples.loc[
        (samples["sample_id"] == sample) &
        (samples["flowcell"] == flowcell) &
        (samples["lane"] == lane)
    ]

    if len(match) != 1:
        raise ValueError(
            f"Expected one match for {sample}, {flowcell}, {lane}; "
            f"found {len(match)}"
        )

    # Return the appropriate FASTQ path
    column = {
        "1": "read1",
        "2": "read2",
        "U": "readU"
    }[read]

    fastq = match.iloc[0][column]

    # Debugging statement if necessary
    #print(f"FASTQ path: {fastq}")

    if not fastq:
        raise ValueError(
            f"No read {read} found for {sample}, {flowcell}, {lane}"
        )

    return fastq

# Function to derive targets for FastQC reports based on existing combos of 
# sample, flowcell, lane and read

FASTQC_TARGETS = {"pre_trim": [], "post_trim": []}

for row in samples.itertuples():
    for read, column in [("1", "read1"), ("2", "read2"), ("U", "readU")]:

        if getattr(row, column):
            filename = f"{row.sample_id}/{row.flowcell}_{row.lane}_{read}.html"

            for stage in FASTQC_TARGETS:
                FASTQC_TARGETS[stage].append(
                    f"results/fastqc_{stage}/{filename}"
                )