#!/bin/bash
# Kyle Hernandez
# Aug 26 2013
# simple-bash-1.sh - Prints the files in the current directory to the console

for fil in ./*; do
    BASE=$(basename $fil)
    PREFIX=${BASE%.*}
    SUFFIX=${BASE#*.}
    echo "NAME=$fil - BASE=$BASE - PREFIX=$PREFIX - SUFFIX=$SUFFIX"
done
