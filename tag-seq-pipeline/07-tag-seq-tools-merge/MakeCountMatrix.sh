#!/bin/bash
#SBATCH -J cm_job
#SBATCH -o cm_job.o%j
#SBATCH -e cm_job.e%j
#SBATCH -n 16
#SBATCH -p development
#SBATCH -t 02:00:00
#SBATCH -A P.hallii_expression

SCRIPT="" # Path to TagSeqTools
GFF=""    # Path to GFF file
INDIR=""  # Path to directory containing ONLY GMCounts output files
OFIL=""   # Output count matrix file

$SCRIPT CountMatrix -i $INDIR -o $OFIL

echo "Parametric job completed..."
date;
