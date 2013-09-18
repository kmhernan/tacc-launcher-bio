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

# Loop over the filtered sam files and
# create a sorted sam file. Here I am assuming that the file names end with "Q20.sam".
# You could simply change sam to bam if they are bam files, or change Q20 to something else if you
# used a differen cutoff value.
for fil in ${INDIR}*Q20.sam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  OUT="${INDIR}${NAME}_sorted.sam"
  OLOG="${LOG}${NAME}.log"
  # We choose SORT_ORDER=coordinate because that's what GATK expects. This is the
  # only sorting option performed by samtools. Note that useing -Xms2G -Xmx4G will require
  # 2 cores / sam file in this instance. If you think that only one would suffice, then -Xms1G -Xmx2G
  # would be appropriate.
  echo -n "java -Xms2G -Xmx4G -jar $SCRIPT INPUT=$fil OUTPUT=$OUT SORT_ORDER=coordinate " >> $PARAM
  # setting MAX_RECORD_IN_RAM can help with memory errors. See Picard http://picard.sourceforge.net/
  echo "MAX_RECORDS_IN_RAM=250000 > $OLOG" >> $PARAM
done
