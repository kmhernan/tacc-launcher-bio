#!/bin/bash
# Kyle Hernandez
# make-sort.sh - Author the parameter file for sorting Sam/Bam files with picard

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
  echo "Usage make-sort.sh in/dir out/dir out.param"
  exit 1;
fi

SCRIPT="/home1/01832/kmhernan/bin/picard-tools-1.92/SortSam.jar"
INDIR=$1
ODIR=$2
PARAM=$3
LOG="logs/"

if [ ! -d $LOG ]; then mkdir $LOG; fi

if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

for fil in ${INDIR}*Q20.bam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  OUT="${INDIR}${NAME}_sorted.bam"
  OLOG="${LOG}${NAME}.log"
  echo -n "java -Xms2G -Xmx4G -jar $SCRIPT INPUT=$fil OUTPUT=$OUT SORT_ORDER=coordinate " >> $PARAM
  echo "MAX_RECORDS_IN_RAM=25000 > $OLOG" >> $PARAM
done
