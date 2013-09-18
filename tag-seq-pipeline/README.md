# 3' tag-seq Pipeline - With a genome and GFF file 

> This is all based on my experience, as there really isn't a consensus on the 'best' methods

## Necessary tools:
* [NGSTools](https://github.com/kmhernan/scalaNGS) - Jar included in the `/utils` directory
* [BWA mem](http://bio-bwa.sourceforge.net/) - Mapping
* [Picard](http://picard.sourceforge.net/) - SAM/BAM files - `module load picard`
* [samtools](http://samtools.sourceforge.net/) - SAM/BAM files - `module load samtools`
* [GATK](http://www.broadinstitute.org/gatk/) - Variant calling and more - `module load gatk`
* [TagSeqTools](https://github.com/kmhernan/tag-seq-tools) - Counting tags and other tools

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
    # Without dynamically trimming polyA tail
    java -Xms1G -Xmx2G -jar NGSTools.jar \
    -T FilterReads \
    -P SE_illumina \
    -I file.fastq \
    -O /path/to/filtered/file.fastq \
    -QV-OFFSET 33 \
    -START 1 -END 36 \
    -MINQ 20 -HPOLY 0.20
    
    # With dynamically trimming polyA tail
    java -Xms1G -Xmx2G -jar NGSTools.jar \
    -T FilterReads \
    -P SE_illumina \
    -I file.fastq \
    -O /path/to/filtered/file.fastq \
    -QV-OFFSET 33 \
    -START 1 -END 36 \
    -MINQ 20 -HPOLY 0.20 \
    -POLYA 0.10 70
    ```

### Phase II: Mapping
1. Use BWA mem with these flags (in addition to the other required arguments): 
    `bwa mem -M -a`
    This forces sub-alignements to be marked as secondary and to output ALL significant alignments

### Phase III: Picard/Samtools (preparing alignments for counting)
1. `SortSam.jar` - Sort SAM files by coordinate - `_sorted.sam`
2. `AddOrReplaceReadGroups.jar` - Add read groups to files - `_RG.sam`
    * `RGID` - Read group id - *job.lane*
    * `RGLB` - Library id - If none, *"Lib-1"*
    * `RGPL` - Platform - *illumina*
    * `RGPU` - Platform Unit - *job-lane.bar*
    * `RGSM` - Sample ID
    * `RGCN` - not required - Sequencing center - *UTGASF*
    * `RGDS` - not required - Description
    * `RGDT` - not required - Sequencing Data - format: `YYYY-MM-DDT00:00:00`
3. `MergeSamFiles.jar` - Merge sam files of a sample together (if necessary) - `SAMPLEID.sam`
4. `SamFormatConverter.jar` - Convert to BAM files and create index - `SAMPLEID.bam`

### Phase IV: Counting
1. Make Counts: `TagSeqTools GMCounts -i <file.bam> -g <file.gff> -o <file.tab> -n <nonoverlapping.tab> [duplicate read choice]`
2. Combine samples into an expression matrix: `TagSeqTools CountMatrix -i <counts/directory/> -o <output-counts.tab>`
3. 

### Expression analaysis is your choice and you can use things like DESeq, edgeR, or JMPgenomics
