#!/bin/bash
# Kyle Hernandez
# make-add-rg.sh - Author AddOrReplaceReadGroups job

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
  echo "Usage make-add-rg.sh in/dir/ out/dir/ out.param"
  exit 1;
fi

SCRIPT="/home1/01832/kmhernan/bin/picard-tools-1.92/AddOrReplaceReadGroups.jar"
INDIR=$1
ODIR=$2
PARAM=$3
LOG="logs/"

if [ ! -d $ODIR ]; then mkdir $ODIR; fi
if [ ! -d $LOG ]; then mkdir $LOG; fi
if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

# See how easy it is if you submit meaningful sample IDs to GSAF
# JOB_SAMPLE_BAR_LANE_.....sam
for fil in ${INDIR}*_sorted.sam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  OUT="${ODIR}${NAME}_RG.sam"
  LOG="${LOG}${NAME}.log"
  # The GSAF JOB ID we appended to the front
  JOB=`echo $NAME | awk -F"_" '{print $1}'`
  # The SAMPLEID, which should be the 2nd index
  SAMP=`echo $NAME | awk -F"_" '{print $2}'`
  # The BARCODE, which the GSAF should add after the sample ID.
  # If not, you can look at the head of the first line like
  # BAR=`head -n1 $fil | awk -F":" '{print $NF}'`
  BAR=`echo $NAME | awk -F"_" '{print $3}'`
  # The LANE, which the GSAF should add after the BAR
  LANE=`echo $NAME | awk -F"_" '{print $4}'`
  echo -n "java -Xms1G -Xmx2G -jar $SCRIPT INPUT=$fil OUTPUT=$OUT SORT_ORDER=coordinate " >> $PARAM
  # These are the conventions used
  echo -n "RGID=${JOB}-${LANE} RGLB=Lib-1 RGPL=illumina RGPU=${JOB}-${LANE}.${BAR} " >> $PARAM
  # RGCN and RGDS aren't required
  echo "RGSM=${SAMP} RGCN=UT-GSAF RGDS=$NAME > $LOG" >> $PARAM
done
