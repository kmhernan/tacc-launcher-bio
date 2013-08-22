#!/bin/bash
#SBATCH -J ref_job	# Job Name
#SBATCH -o ref_job.o%j  # Job standard output file
#SBATCH -e ref_job.e%j  # Job standard error file
#SBATCH -n 1 		# Wayness
#SBATCH -p development  # Queue
#SBATCH -t 03:00:00  	# Time
#SBATCH -A P.hallii_expression # Account

SCRIPT="/home1/01832/kmhernan/bin/picard-tools-1.92/CreateSequenceDictionary.jar"
REF="/scratch/01832/kmhernan/C3RMP/data/reference/Cre_comp_ref.fa"
OUT="/scratch/01832/kmhernan/C3RMP/data/reference/Cre_comp_ref.dict"

module load samtools

java -Xmx2G -jar $SCRIPT REFERENCE=$REF OUTPUT=$OUT GENOME_ASSEMBLY=Creinhardtii_236 SPECIES=Chlamydomonas
samtools faidx $REF
date;
