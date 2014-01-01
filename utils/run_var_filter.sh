#!/bin/bash
# Kyle Hernandez
# Bash script to run GATK. Assumes you are using module load gatk/version in your job script.
# These filters are geared for more deeply sequenced WGS reads.
# You may need to play with the java memory args.

echoerr() {
        echo "$@" 1>&2;
}

if [[ -z $1 ]] | [[ -z $2 ]] | [[ -z $3 ]]; then
        echoerr "Usage: run_var_filter.sh <input.vcf> <output.vcf> <reference.fa>"
        exit 1
fi

GATK="${TACC_GATK_DIR}GenomeAnalysisTK.jar"
INFIL=$1
OFIL=$2
REF=$3

java -Xmx1G -jar $GATK -R $REF -T VariantFiltration -o $OFIL --variant $INFIL --clusterSize 3 --clusterWindowSize 10 \
--filterExpression "MQ0 >= 4 && ((MQ0 >= (1.0 * DP)) > 0.1)" --filterName "HARD_TO_VALIDATE" \
--filterExpression "DP < 6" --filterName "LowCoverage" --filterExpression "QUAL < 30.0" --filterName "VeryLowQual" \
--filterExpression "QUAL >= 30.0 && QUAL < 50.0" --filterName "LowQual" --filterExpression "QD < 1.5" --filterName "LowQD" \
--filterExpression "SB > -10.0" --filterName "StrandBias"
