# -*- coding: utf-8 -*-
# Kyle Hernandez
import sys
import itertools
import os
import glob

def load_ref():
    '''
    Loads the samtools index reference fai into a list
    '''
    fai = ref_file + '.fai'
    scf_lst = []
    for line in open(fai, 'rU'):
        scf_lst.append(line.rstrip())
    return scf_lst

def grouper(n, iterable, fillvalue=None):
    '''
    Grouper helper for making groups of size N
    '''
    args = [iter(iterable)] * n
    return itertools.izip_longest(*args, fillvalue=fillvalue)

if __name__=='__main__':
    '''
    These are hardcoded and you will need to change them and is intended for Phalli reference.
    ref_file - I assume the 'fai' file is in the same location as your ref_file
    bam_dir  - Directory containing all the BAM files you wish to call genotypes in
    out_dir  - Output parent directory for VCF files
    interval - Directory where the 'fai' intervals will be written to
    param    - Parameter file for TACC launcher (output)
    bam_list - Will create this file to read into mpileup with the paths for all BAM files
    var_filter_script - Path to the run_var_filter.sh script
    '''
    
    ref_file = '/scratch/01832/kmhernan/References/Phallii/assembly_v_0_5/Panicum_hallii.main_genome.scaffolds.fasta'
    bam_dir  = '/scratch/01832/kmhernan/chk_david/data/bam'
    out_dir  = '/scratch/01832/kmhernan/chk_david/data/VCF'
    interval = '/scratch/01832/kmhernan/chk_david/par_mpile/intervals'
    param    = '/scratch/01832/kmhernan/chk_david/par_mpile/mpile_split.param'
    bam_list = '/scratch/01832/kmhernan/chk_david/par_mpile/files.list'
    var_filter_script = '/scratch/01832/kmhernan/chk_david/par_mpile/run_var_filter.sh'

    # Load reference fai
    scaff_list = load_ref()
    # Big scaffolds
    first = scaff_list[0:240]
    # Smaller scaffolds
    rest  = scaff_list[240::]

    # Make bam list file
    with open(bam_list, 'wb') as obam:
        for fil in sorted(glob.glob(bam_dir + '/*.bam')):
            obam.write(fil + '\n')

    # Counts for characters
    at = 97
    ct = 97

    # Open parameter file
    o_par = open(param, 'wb')
        # Process big scaffolds
    for k in grouper(10, first):
        name = "contig-" + chr(at) + chr(ct)
        o_int = os.path.join(interval, name + ".intervals")
        o_fai = open(o_int, 'wb')
        o_fai.write('\n'.join([i for i in k if i]) + "\n")
        o_fai.close()

        o_tmp = os.path.join(out_dir, name)
        if not os.path.isdir(o_tmp):
            os.makedirs(o_tmp)
        tmp_bcf = os.path.join(o_tmp, 'tmp.{}.bcf')
        tmp_vcf = os.path.join(o_tmp, 'tmp.{}.vcf')
        flt_vcf = os.path.join(o_tmp, 'tmp.{}.flt.vcf')

        o_par.write('vcfutils.pl splitchr -l 1000000 ' + o_int + ' | xargs -I {} -n 1 -P 16 sh -c "samtools mpileup ' + \
                    '-m 3 -F 0.0002 -SDuf ' + ref_file + ' -q 10 -r {} -b ' + bam_list + ' | bcftools view ' + \
                    '-bcvg - > ' + tmp_bcf + ' && bcftools view ' + tmp_bcf + ' | vcfutils.pl varFilter -D1000 - > ' + \
                    tmp_vcf + ' && ' + var_filter_script + ' ' + tmp_vcf + ' ' + flt_vcf + ' ' + ref_file + '"\n')

        if ct < 122:
            ct += 1
        else:
            ct = 97
            at += 1

    # Process small scaffolds
    for k in grouper(100, rest):
        name = "contig-" + chr(at) + chr(ct)
        o_int = os.path.join(interval, name + ".intervals")
        o_fai = open(o_int, 'wb')
        o_fai.write('\n'.join([i for i in k if i]) + "\n")
        o_fai.close()

        o_tmp = os.path.join(out_dir, name)
        if not os.path.isdir(o_tmp):
            os.makedirs(o_tmp)
        tmp_bcf = os.path.join(o_tmp, 'tmp.{}.bcf')
        tmp_vcf = os.path.join(o_tmp, 'tmp.{}.vcf')
        flt_vcf = os.path.join(o_tmp, 'tmp.{}.flt.vcf')

        o_par.write('vcfutils.pl splitchr -l 1000000 ' + o_int + ' | xargs -I {} -n 1 -P 16 sh -c "samtools mpileup ' + \
                    '-m 3 -F 0.0002 -SDuf ' + ref_file + ' -q 10 -r {} -b ' + bam_list + ' | bcftools view ' + \
                    '-bcvg - > ' + tmp_bcf + ' && bcftools view ' + tmp_bcf + ' | vcfutils.pl varFilter -D1000 - > ' + \
                    tmp_vcf + ' && ' + var_filter_script + ' ' + tmp_vcf + ' ' + flt_vcf + ' ' + ref_file + '"\n')

        if ct < 122:
            ct += 1
        else:
            ct = 97
            at += 1
    o_par.close()
