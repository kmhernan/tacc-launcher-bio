#!/bin/bash
#SBATCH -J snpfiltjob
#SBATCH -o snpfiltjob.o%j
#SBATCH -e snpfiltjob.e%j
#SBATCH -n 16
#SBATCH -p development
#SBATCH -t 02:00:00
#SBATCH -A P.hallii_expression

SCRIPT="${GATK}/GenomeAnalysisTK.jar"
INDEL="" # Path to inDels-Q20.vcf
VCF="" # Path to raw-SNP-Q20-annotated.vcf
OUT="" # Path to Q30-SNPS.vcf
PASS="" # Path to only-PASS-Q30-SNPS.vcf
REF="" # Path to ref
LOGS="snp-filter.logs"

java -Xms10G -Xmx25G -jar $SCRIPT \
-T VariantFiltration \
-R $REF \
-V $VCF \
--mask $INDEL \
--maskExtension 5 \
--maskName inDel \
--clusterWindowSize 10 \
--filterExpression "QUAL < 30.0" \
--filterName "LowQual" \
-o $OUT

# Now we parse out only the SNPs that passed
cat $OUT | grep 'PASS\|#' > $PASS

echo "DONE";
