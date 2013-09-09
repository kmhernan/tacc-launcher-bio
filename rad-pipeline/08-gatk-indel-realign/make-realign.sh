#!/bin/bash
# Kyle Hernandez
# make-realign.sh - create parameter files for the IndelRealigner targets and realigned BAM files.

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]] | [[ -z $4 ]]; then
  echo "Usage make-indel-ra.sh in/dir/ out/target/ out/realigned/ reference.fa"
  exit 1;
fi

SCRIPT="${GATK}/GenomeAnalysisTK.jar"
INDIR=$1
TARGET=$2
RADIR=$3
REF=$4

# We have 2 parameter files because this is a 2 part step
PGRP="targets.param"
PBAM="bam.param"
LOGS="logs/"

if [ ! -d $LOGS ]; then mkdir $LOGS; fi
if [ -e $PGRP ]; then rm $PGRP; fi
if [ -e $PBAM ]; then rm $PBAM; fi
touch $PGRP
touch $PBAM

for fil in ${INDIR}*.bam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  # Indel realigner targets file
  OTARG="${TARGET}${NAME}_RA.intervals"
  # Indel realigner bam file
  ORA="${RADIR}${NAME}_RA.bam"
  # Log files. One for each step.
  LOGTAR="${LOGS}${NAME}_target.log"
  LOGRA="${LOGS}${NAME}_realigned.log"
  # Write the first step, which is the target creator to PGRP
  # I add some more filtering like --minReadsAtLocus 2
  echo -n "java -Xms2G -Xmx4G -jar $SCRIPT " >> $PGRP
  echo -n "-T RealignerTargetCreator -nt 2 " >> $PGRP
  echo "-I $fil -R $REF --minReadsAtLocus 2 -o $OTARG > $LOGTAR" >> $PGRP

  # Write the second step, which is the writing the realigned BAM files.
  # I add some extra filtering like -LOD 3.0
  echo -n "java -Xms2G -Xmx4G -jar $SCRIPT " >> $PBAM
  echo -n "-T IndelRealigner " >> $PBAM
  echo "-I $fil -R $REF -targetIntervals $OTARG -LOD 3.0 -o $ORA > $LOGRA" >> $PBAM
done
