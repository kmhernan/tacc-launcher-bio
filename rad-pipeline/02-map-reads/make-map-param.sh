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

# For most cases where you have your filtered/trimmed reads in one directory like
# /data/filtered-reads/
for fil in ${INDIR}*; do
    BASE=$(basename $fil)
    NAME=${BASE%.fastq}
    OFIL="${ODIR}${NAME}.sam"
    # See SHRiMP README... -o 5 outputs at most 5 best hits.
    echo "$SCRIPT -o 5 -N 4 -Q --qv-offset 33 -L $REF $fil > $OFIL" >> $PARAM
done

# For cases where you don't have JOBID appended to the front of your fastq files.
# Here, I assume you have reads organized in folders that are named the JOBID.
# A structure like:
# /data/filtered-reads/JA1234/
# /data/filtered-reads/JA1235/
# etc. This will take that bottom folder name (which I assume is the jobid) append it to the 
# filename for the OUTPUT SAM file.
#
#for dir in ${INDIR}*; do
#    JOB=$(basename $dir)
#    for fil in ${dir}/*; do
#       BASE=$(basename $fil)
#	NAME=${BASE%.fastq}
#	OFIL="${ODIR}${JOB}_${NAME}.sam"
#	echo "$SCRIPT -o 5 -N 4 -Q --qv-offset 33 -L $REF $fil > $OFIL" >> $PARAM
#    done
#done


##### Finally, if your fastq files don't have the barcodes in the filenames and the header lines
##### are of this format
#####     @HWI-ST1097:230:C2216ACXX:6:1101:1822:2095 1:N:0:TACGTG
##### This is a great place to pull out the barcode and add it to the filename to save a headache down the line
##### You can do something like:
##### BAR=`head -n1 $fil | awk -F":" '{print $NF}'`
##### to read the barcode from the header line from file $fil into the variable BAR... you can then add it to the
##### name of your output sam file.
