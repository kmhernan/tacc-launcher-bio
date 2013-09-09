#!/bin/bash
#SBATCH -J annotatejob
#SBATCH -o annotatejob.o%j
#SBATCH -e annotatejob.e%j
#SBATCH -n 16
#SBATCH -p development
#SBATCH -t 02:00:00
#SBATCH -A P.hallii_expression

SCRIPT="${GATK}/GenomeAnalysisTK.jar" # Path to GATK, or module load gatk
INDIR="" # Path to realigned bam
VCF="" # Path to raw-SNP-Q20.vcf
OUT="raw-SNP-Q20-annotated.vcf"
REF="" # Path to ref
FILES="files.list"
LOGS="snp-annotate.logs"

if [ -e $FILES ]; then rm $FILES; fi
touch $FILES

for fil in ${INDIR}*.bam; do
  echo $fil >> $FILES
done

# Since we don't have fancy databases, we pretty much can only use these flags
java -Xms2G -Xmx10G -jar $SCRIPT -T VariantAnnotator \
-I $FILES \
-G StandardAnnotation \
-R $REF \
-V:variant,VCF $VCF \
-XA SnpEff \
-o $OUT
echo "DONE";
