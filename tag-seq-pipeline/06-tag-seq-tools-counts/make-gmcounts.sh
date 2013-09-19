#!/bin/bash
# Kyle Hernandez
# Septemger 19 2013
# make-gmcounts.sh - authors a parameter file to count tag pileups based on a gene model

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]]; then
    echo "Usage: make-gmcounts.sh <in/bam/dir/> <file.gff> <counts/dir/> <non-overlap/dir/>"
    exit 1
fi

# INDIR  - a directory of bam files you wish to create counts for
# GFF    - The GFF file for the reference you mapped your tags to. [only GFF3 tested]
# OFIL   - Output directory for count files for each bam file 
# NONDIR - Output directory for spilling non-overlapping pileups

INDIR=$1
GFF=$2
OFIL=$3
NONDIR=$4
# You will want to put the path to TagSeqTools binary
SCRIPT="/home1/01832/kmhernan/bin/switchgrass-expression/cpp/TagSeqTools/bin/TagSeqTools"
PARAM="gm.param"
LOGS="logs/"

if [ ! -d $LOGS ]; then mkdir $LOGS; fi
if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

# Loop over your bam files in this directory
for fil in ${INDIR}*bam; do
    BASE=$(basename $fil)
    NAME=${BASE%.*}
    OFIL="${ODIR}${NAME}.tab"
    ONON="${NONDIR}${NAME}_non.tab"
    OLOG="${LOGS}${NAME}.log"
    # The flags for dealing with duplicates:
    # no flags     - default - ignore all duplicately mapped reads
    # --random-one - randomly choose one PACID to add a count to for multimapped read
    # --primary-alignment - Use only primary-alignments. Require BAM flags contain
    #  			    this information. (e.g., bwa mem -M)
    # --split-counts - Distribute counts across all targets evenly.
    # Other flags:
    # --flag-dups - <testing only> - Append '_DUP' to PACIDs with duplicate reads
    echo "$SCRIPT -i $fil -g $GFF -o $OFIL -n $ONON --random-one > $OLOG" >> $PARAM
done
