#!/bin/bash
#SBATCH -J ref_job         # Job Name
#SBATCH -o ref_job.o%j      # Output file name (%j expands to jobID)
#SBATCH -e ref_job.e%j      # Error file name (%j expands to jobID)
#SBATCH -n 16
#SBATCH -p development
#SBATCH -t 03:00:00        # Run time (hh:mm:ss) - 1.5 hours
#SBATCH -A switchgrass_454

SCRIPT="/home1/01832/kmhernan/bin/SHRiMP_2_2_3/bin/gmapper-ls"

$SCRIPT -N 16 -S phalli_late_great.genome Phallii_late_great.fasta

date;
