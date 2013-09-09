#!/bin/bash
# Kyle Hernandez
# make-recalibrate.sh - create parameter files for base recalibration. Multi step.

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]] | [[ -z $4 ]] | [[ -z $5 ]]; then
    echo -n "Usage: make-recalibrate.sh </hq-vcf/dir/> </indel-realign-bam/dir/> <reference.fa> "
    echo "</out/group/dir/> </out/recal-bam/dir/>"
    exit 1 
fi
SCRIPT="${GATK}/GenomeAnalysisTK.jar"
INHQ=$1
INRA=$2
REF=$3
GRP=$4
BAM=$5
LOG="logs/"
# Need one parameter file for each step
BPARAM="base-recal.param"
PPARAM="print-reads.param"

if [ ! -d $LOG ]; then mkdir $LOG; fi
if [ -e $BPARAM ]; then rm $BPARAM; fi
if [ -e $PPARAM ]; then rm $PPARAM; fi
touch $BPARAM
touch $PPARAM

# Loop through the indel realigned bam folder
for fil in ${INRA}*.bam; do
    BASE=$(basename $fil)
    NAME=${BASE%_*}
    # HQ VCF file for this sample
    VCF="${INHQ}${NAME}_HQ.vcf"
    # Output recalibrator group file
    OGRP="${GRP}${NAME}_recal.grp"
    # Output recalibrator bam file
    OBAM="${BAM}${NAME}_recal.bam"
    # Logs
    GLOG="${LOG}${NAME}_group.log"
    BLOG="${LOG}${NAME}_print.log"
    # First we do base recal groups
    # These do like more RAM 
    echo -n "java -Xms2G -Xmx4G -jar $SCRIPT -T BaseRecalibrator -I $fil -R $REF " >> $BPARAM
    echo    "-knownSites $VCF -o $OGRP > $GLOG" >> $BPARAM

    # Then we print recalibrated BAM file
    echo -n "java -Xms2G -Xmx4G -jar $SCRIPT -T PrintReads -I $fil -R $REF " >> $PPARAM
    echo    "-BQSR $OGRP -o $OBAM > $BLOG" >> $PPARAM
done
