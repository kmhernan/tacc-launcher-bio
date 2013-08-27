#!/bin/bash

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]] | [[ -z $4 ]]; then
  echo "Usage make-indel-ra.sh in/dir/*.bam out/target/ out/realigned/ reference.fa" 
  exit 1;
fi

SCRIPT="${GATK}/GenomeAnalysisTK.jar"
INDIR=$1
TARGET=$2
RADIR=$3
REF=$4
TPARAM="target.param"
BPARAM="bam.param"
TLOGS="target-logs/"
BLOGS="bam-logs/"

if [ -e $TPARAM ]; then rm $TPARAM; fi
if [ -e $BPARAM ]; then rm $BPARAM; fi
touch $TPARAM
touch $BPARAM

if [ ! -d $TLOGS ]; then mkdir $TLOGS; fi
if [ ! -d $BLOGS ]; then mkdir $BLOGS; fi

for fil in $INDIR; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  SP=${NAME%_*}
  OTARG="${TARGET}${NAME}_RA.intervals"
  ORA="${RADIR}${NAME}_RA.bam"
  LOGTAR="${TLOGS}${NAME}_target.log"
  LOGRA="${BLOGS}${NAME}_realigned.log"
  if [[ "$SP" =~ "F1" ]]; then
      echo -n "java -Xms2G -Xmx28G -jar $SCRIPT " >> $TPARAM
      echo -n "-T RealignerTargetCreator -nt 8 " >> $TPARAM
      echo "-fixMisencodedQuals -I $fil -R $REF --minReadsAtLocus 2 -o $OTARG > $LOGTAR" >> $TPARAM

      echo -n "java -Xms2G -Xmx28G -jar $SCRIPT " >> $BPARAM
      echo -n "-T IndelRealigner " >> $BPARAM
      echo "-fixMisencodedQuals -I $fil -R $REF -targetIntervals $OTARG -LOD 3.0 -o $ORA > $LOGRA" >> $BPARAM
  else
      echo -n "java -Xms2G -Xmx28G -jar $SCRIPT " >> $TPARAM
      echo -n "-T RealignerTargetCreator -nt 8 " >> $TPARAM
      echo "-I $fil -R $REF --minReadsAtLocus 2 -o $OTARG > $LOGTAR" >> $TPARAM

      echo -n "java -Xms2G -Xmx28G -jar $SCRIPT " >> $BPARAM
      echo -n "-T IndelRealigner " >> $BPARAM
      echo "-I $fil -R $REF -targetIntervals $OTARG -LOD 3.0 -o $ORA > $LOGRA" >> $BPARAM
  fi
done
