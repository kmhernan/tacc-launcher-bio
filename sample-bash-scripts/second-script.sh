#!/bin/bash
# Kyle Hernandez
# Aug 26 2013
# simple-bash-2.sh - Takes user arguments to print files

if [[ -z $1 ]]; then
    echo "Usage: simple-bash-2.sh <in/dir/>"
    exit 1
fi 

INDIR=$1
for fil in ${INDIR}*; do
    echo $fil
done
