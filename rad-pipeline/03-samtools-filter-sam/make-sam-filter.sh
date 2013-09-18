#!/bin/bash
# Kyle Hernandez
# make-sam-filter.sh - Author parameter file for samtools filter on mapq

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
  echo "Usage make-filt.sh in/dir/ out/dir/ out.param"
  exit 1;
fi

INDIR=$1
ODIR=$2
PARAM=$3

if [ ! -d $ODIR ]; then mkdir $ODIR; fi

if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

# If you want the output to be a bam file use this:
for fil in ${INDIR}*.sam; do
  BASE=$(basename $fil)
  NAME=${BASE%.*}
  OUT="${ODIR}${NAME}_Q20.bam"
  # Note that the -q 20 will filter alignments with mapq less than 20.
  # Hence, why I add _Q20 to the output file name.
  echo "samtools view -bSh -q 20 $fil > $OUT" >> $PARAM
done

# If you want the output to be a sam file use this:
#for fil in ${INDIR}*.sam; do
#  BASE=$(basename $fil)
#  NAME=${BASE%.*}
#  OUT="${ODIR}${NAME}_Q20.bam"
#  echo "samtools view -Sh -q 20 $fil > $OUT" >> $PARAM
#done
