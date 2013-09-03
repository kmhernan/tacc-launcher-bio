#!/bin/bash

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
  echo "Usage make-add-rg.sh in/dir/ out/dir/ out.param"
  exit 1;
fi

SCRIPT="/home1/01832/kmhernan/bin/picard-tools-1.92/AddOrReplaceReadGroups.jar"
INDIR=$1
ODIR=$2
PARAM=$3
if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

for fil in ${INDIR}*_sorted.bam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  OUT="${ODIR}${NAME}_RG.bam"
  JOB=`echo $NAME | awk -F"_" '{print $1}'`
  SAMP=`echo $NAME | awk -F"_" '{print $2}'`
  BAR=`echo $NAME | awk -F"_" '{print $3}'`
  LANE=`echo $NAME | awk -F"_" '{print $4}'`
  echo -n "java -Xms1G -Xmx2G -jar $SCRIPT INPUT=$fil OUTPUT=$OUT SORT_ORDER=coordinate " >> $PARAM
  echo -n "RGID=${JOB}-${LANE} RGLB=Lib-1 RGPL=illumina RGPU=${JOB}-${LANE}.${BAR} " >> $PARAM
  echo "RGSM=${SAMP} RGCN=UT-GSAF RGDS=$NAME" >> $PARAM
done
