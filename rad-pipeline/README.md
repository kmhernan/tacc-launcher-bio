# 2bRAD Pipeline
## Non-model organisms

## Four phases

### Phase I: Quality Control
1. `NGSTools.jar` - Look at base composition and quality distribution
2. `NGSTools.jar` - Trim and filter
    * Alf example: `java -Xms1G -Xmx2G -jar NGSTools.jar -T ReadStatistics -P SE_illumina -QV-OFFSET 33 -START 1 -END 36 -MINQ 20 -HPOLY 0.20`

### Phase II: Mapping
1. SHRiMP - Take your reference [preferable indexed] and your filtered/trimmed fastq files. Output is SAM.

### Phase III: Picard/Samtools (preparing alignments for GATK)
1. `samtools` - Filter out high quality mappings - `_Q20.sam`
    * `samtools view -Sh -q 20`
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
3. `UnifiedGenotyper` - First run to call SNPs - *We go from 1 BAM file/Sample to 1 VCF files representing ALL samples*
    * Input: files.list, Reference
    * Outptut: rawSNP-Q20.vcf
4. `VariantAnnotator` - Adds annotations for filtering
    * Input: rawSNP-Q20.vcf, 
