#!/bin/bash
#SBATCH -J snpgencalljob
#SBATCH -o snpgencalljob.o%j
#SBATCH -e snpgencalljob.e%j
#SBATCH -n 16
#SBATCH -p normal
#SBATCH -t 10:00:00
#SBATCH -A P.hallii_expression

SCRIPT="${GATK}/GenomeAnalysisTK.jar" # Path to gatk, or you can use module load gatk
INDIR="" # Path to the realigned BAM files
OUT="" # Path to raw-SNP-Q20.vcf output file
REF="" # Path to reference
FILES="files.list" # The name of the list of bam files to read into GATK. We will create this.
LOGS="snp-model.logs" # Name of the output log

# Check if the files list exists, and remove it if it does
if [ -e $FILES ]; then rm $FILES; fi
touch $FILES

# Loop through the realigned bam files and append the path to the files.list file
for fil in ${INDIR}*.bam; do
  echo $fil >> $FILES
done

# Now run GATK for SNPs only
# The stand_call_conf is the min quality score that GATK will use to call a SNP,
# while the stand_emit_conf is the min quality score that GATK will use to OUTPUT a SNP into the VCF.
# So, call_conf is <= emit_conf . You can add more flags to have GATK output all called SNPs (> call_conf), but 
# will mark SNPs with qual > emit_conf as 'PASS' filter. 
# see http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_genotyper_UnifiedGenotyper.html
java -Xms10G -Xmx25G -jar $SCRIPT -T UnifiedGenotyper \
-nct 4 -nt 4 \
-I $FILES \
-stand_call_conf 20.0 \
-stand_emit_conf 20.0 \
-glm SNP \
-gt_mode DISCOVERY -R $REF -o $OUT > $LOGS

echo "DONE";
