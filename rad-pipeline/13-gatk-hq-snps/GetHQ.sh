#!/bin/bash
#SBATCH -J HQ_job          # Job Name
#SBATCH -o HQ_job.o%j      # Output file name (%j expands to jobID)
#SBATCH -e HQ_job.e%j      # Error file name (%j expands to jobID)
#SBATCH -n 16
#SBATCH -p development
#SBATCH -t 04:00:00        # Run time (hh:mm:ss) - 1.5 hours
#SBATCH -A P.hallii_expression

# You must do this
module load python

# Globals
SCRIPT="" # Path to GetHighQualVcf.py
INDIR="" # Path to only-PASS-Q30-SNPS.vcf
ODIR="" # Path to high quality snps directory 

$SCRIPT -i $INDIR -o $ODIR

echo "DONE"
date;
