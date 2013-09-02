#!/bin/bash
# Kyle Hernandez
# Sep 2 2013
# make-filter-param.sh - makes parameter file for running the read trim/filter 

# Check for required arguments
if [[ -z $1 ]] | [[ -z $2 ]]; then
    echo "usage: make-filter-param.sh </raw-fastq-parent/path/> </output-path/>"
    exit 1;
fi

# Declare variables
DIRS=$1
ODIR=$2
CMD="Filter-File.param"
LOG="logs/"
SCRIPT="java -Xms1G -Xmx2G -jar /home1/01832/kmhernan/bin/NGStools.jar -T FilterReads -P SE_illumina"

if [ ! -d $ODIR ]; then mkdir $ODIR; fi
if [ ! -d $LOG ]; then mkdir $LOG; fi
if [ -e $CMD ]; then rm $CMD; fi
touch $CMD

# Loop through directories in parent directory
# /parent-dir/JA1234
# /parent-dir/JA1235
# /parent-dir/JA1236
for dir in ${DIRS}*; do
    # Since we have named the directory the JOB ID
    # we extract it like so
    CURR=$(basename $dir)

    # We now can create the output path for the filtered reads
    # by concatenating $ODIR and $CURR, but we also need to automate the creation of this directory
    OP="${ODIR}${CURR}/"
    if [ ! -d $OP ]; then mkdir $OP; fi

    # Now we loop through each fastq file in the current 
    # Job directory
    for fil in ${dir}/*; do
        BASE=$(basename $fil)   	 # file name without the path
        NAME=${BASE%.fastq.gz*} 	 # file name without .fastq.gz
        OFIL="${ODIR}${JOB}_${NAME}.tab" # output file name. Add JOB ID to front
        OLOG="${LOG}${NAME}.log"	 # output log file for this fastq file

	# Now we append to the command/parameter file
        # Use the -n flag for echo to not automatically add a new line
        # to the end of the echo command so we won't have to have a really long
     	# line in this file
        echo  -n "$SCRIPT -I $fil -O $OFIL -QV-OFFSET 33 -START 1 " >> $CMD
        echo "-END 36 -HPOLY 0.20 -MINQ 10 -NMISSING 5 > $OLOG" >> $CMD
    done # exit the file for loop
done # exit the directory for loop
