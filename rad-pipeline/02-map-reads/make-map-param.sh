#!/bin/bash
# Kyle Hernandez
# Aug 29 2013
# make-map-param.sh - makes parameter file for mapping using SHRiMP 

# Check for required arguments
if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
    echo "usage: make-qr-param.sh </filtered-fastq-path/> </output-path/> <reference.genome>"
    exit 1;
fi

# Declare variables
DIRS=$1
ODIR=$2
REF=$3
PARAM="Shrimp-File.param"
LOG="logs/"
SCRIPT="/home1/01832/kmhernan/bin/SHRiMP_2_2_3/bin/gmapper-ls/"

if [ -e $PARAM ]; then rm $PARAM; fi
touch $PARAM

for dir in ${INDIR}*; do
    JOB=$(basename $dir)
    for fil in ${dir}/*; do
        BASE=$(basename $fil)
	NAME=${BASE%.fastq}
	OFIL="${ODIR}${JOB}_${NAME}.sam"
	echo "$SCRIPT -o 5 -N 4 -Q --qv-offset 33 -L $REF $fil > $OFIL" >> $PARAM
    done
done
