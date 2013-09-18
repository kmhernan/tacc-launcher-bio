# 3' tag-seq Pipeline - With a genome and GFF file 

> This is all based on my experience, as there really isn't a consensus on the 'best' methods

## Necessary tools:
* [NGSTools](https://github.com/kmhernan/scalaNGS) - Jar included in the `/utils` directory
* [SHRiMP](http://compbio.cs.toronto.edu/shrimp/) - Mapping - *you can use BWA aln if you wish*
* [Picard](http://picard.sourceforge.net/) - SAM/BAM files - `module load picard`
* [samtools](http://samtools.sourceforge.net/) - SAM/BAM files - `module load samtools`
* [GATK](http://www.broadinstitute.org/gatk/) - Variant calling and more - `module load gatk`

## Four phases

### Phase I: Quality Control
1. `NGSTools.jar` - Look at base composition and quality distribution

    ```bash
    java -Xms1G -Xmx2G -jar NGSTools.jar \
    -T ReadStatistics \
    -I file.fastq \
    -O file.tab \
    -QV-OFFSET 33
    ```
    
2. `NGSTools.jar` - Trim and filter - *If you are going to use BWA mem you must keep read lengths > 70*

    ```bash
    java -Xms1G -Xmx2G -jar NGSTools.jar \
    -T FilterReads \
    -P SE_illumina \
    -I file.fastq \
    -O /path/to/filtered/file.fastq \
    -QV-OFFSET 33 \
    -START 1 -END 36 \
    -MINQ 20 -HPOLY 0.20
    ```

### Phase II: Mapping
1. SHRiMP - Take your reference [preferable indexed] and your filtered/trimmed fastq files. Output is SAM.

### Phase III: Picard/Samtools (preparing alignments for GATK)
1. `samtools` - Filter out high quality mappings - `_Q20.sam`
    * `samtools view -Sh -q 20 file.sam > file_Q20.sam`
2. `SortSam.jar` - Sort SAM files by coordinate - `_sorted.sam`
3. `AddOrReplaceReadGroups.jar` - Add read groups to files - `_RG.sam`
    * `RGID` - Read group id - *job.lane*
    * `RGLB` - Library id - If none, *"Lib-1"*
    * `RGPL` - Platform - *illumina*
    * `RGPU` - Platform Unit - *job-lane.bar*
    * `RGSM` - Sample ID *Important because this is what GATK will use for the sample columns in the VCF*
    * `RGCN` - not required - Sequencing center - *UTGASF*
    * `RGDS` - not required - Description
    * `RGDT` - not required - Sequencing Data - format: `YYYY-MM-DDT00:00:00`
4. `MergeSamFiles.jar` - Merge sam files of a sample together (if necessary) - `SAMPLEID.sam`
5. `SamFormatConverter.jar` - Convert to BAM files and create index - `SAMPLEID.bam`

### Phase IV: GATK Round One
1. `RealignerTargetCreator` - Create target intervals for indel realignment - `_RA.intervals`
    * Input: SAMPLEID.bam, Reference
    * Output: SAMPLEID_RA.intervals
2. `IndelRealigner` - Create realigned BAM files - `_RA.bam`
    * Input: SAMPLEID.bam, Reference, SAMPLEID_RA.intervals
    * Output: SAMPLEID_RA.bam
3. `UnifiedGenotyper` - First run to call SNPs - *We go from 1 BAM file/Sample to 1 VCF file representing ALL samples*
    * Input: files.list, Reference
    * Output: raw-SNPs-Q20.vcf
4. `VariantAnnotator` - Adds annotations for filtering
    * Input: files.list, rawSNP-Q20.vcf, Reference
    * Output: raw-SNPs-Q20-annotated.vcf
5. `UnifiedGenotyper` - Now run to call Indels only - *We go from 1 BAM file/Sample to 1 VCF file representing ALL samples*
    * Input: files.list, Reference
    * Output: inDels-Q20.vcf
6. `VariantFiltration` - Filter SNPs around indels, low qual SNPs
    * Input: raw-SNPs-Q20-annotated.vcf, Reference, inDels-Q20.vcf
    * Output: Q30-SNP.vcf
    * Example:

    ```bash
    java -jar -Xmx10G -Xmx25G -jar GenomeAnalysisTK.jar \
    -T VariantFiltration \
    -R Reference.fa \
    -V raw-SNPS-Q20-annotated.vcf \
    --mask inDels-Q20.vcf \
    --maskExtension 5 \
    --maskName inDel \
    --clusterWindowSize 10 \
    --filterExpression "QUAL < 30.0" \
    --filterName "LowQual" \
    -o Q30-SNP.vcf
    ```

7. Parse passing SNPs to VCF file
    * Input: Q30-SNP.vcf
    * Output: only-PASS-Q30-SNPS.vcf
    * Command: `cat Q30-SNP.vcf | grep 'PASS\|#' > only-PASS-Q30-SNPS.vcf`
8. `GetHighQualVcf.py` - Now we pull out the SNPs in the top 95th percentile, split into INDIVIDUAL (e.g., by sample) VCFs - `SAMPLEID_HQ.vcf`
    * Input: only-PASS-Q30-SNPS.vcf
    * Output: SAMPLEID_HQ.vcf
    * Command: `GetHighQualVcf.py -i only-PASS-Q30-SNPS.vcf -o /path/to/hq-snps/`

### Phase IV: GATK Round Two
1. `BaseRecalibrator` - create recalibrator groups for each SAMPLE - `SAMPLEID_recal.grp`
    * Input: SAMPLEID_RA.bam, Reference, SAMPLEID_HQ.bam
    * Output: SAMPLEID_recal.grp
2. `PrintReads` - Print new BAM file with recalibrated base qualities - `SAMPLEID_recal.bam`
    * Input: SAMPLEID_RA.bam, Reference, SAMPLEID_recal.grp
    * Output: SAMPLEID_recal.bam
3. `UnifiedGenotyper` - Final run of genotyper, usually call both indel and snps - *We go from 1 recalibrated BAM/sample to one VCF file containing all samples*
    * Input: recal-bam-file.list, Reference
    * Output: final-GT-Q20.vcf
    * Example:

    ```bash
    java -Xmx10G -Xmx29G -jar GenomeAnalysisTK.jar \
    -T UnifiedGenotyper \
    -nct 4 -nt 4 \
    -I recal-bam-file.list \
    -stand_call_conf 20.0 \
    -stand_emit_conf 20.0 \
    -glm BOTH -gt_mode DISCOVERY \
    -R Reference.fa \
    -o final-GT-Q20.vcf
    ```
