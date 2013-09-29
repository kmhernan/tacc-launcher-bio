import os
import itertools
import glob

contigs   = "contigs.txt"
ref       = "/scratch/01832/kmhernan/References/Phallii/assembly_v_0_5/Panicum_hallii.main_genome.scaffolds.fasta"
intervals = "intervals/"
logs      = "logs/"
indir     = "/scratch/01832/kmhernan/FH_Reseq/results/GATK/indel-realign-bam/"
odir      = "/scratch/01832/kmhernan/FH_Reseq/results/GATK/first-unified/indel-splits/"
param     = "indel-splits.param"
script    = "java -Xms10G -Xmx28G -jar /home1/01832/kmhernan/bin/GATK-2.5-2/GenomeAnalysisTK.jar " + \
            "-T UnifiedGenotyper -nct 4 -nt 4"
filters   = "--read_filter BadMate --read_filter NotPrimaryAlignment " + \
            "--read_filter DuplicateRead --read_filter MappingQualityZero -glm INDEL " + \
            "-gt_mode DISCOVERY -maxAltAlleles 3 -stand_call_conf 20 -stand_emit_conf 30"

# grouper helper 
def grouper(n, iterable, fillvalue=None):
    args = [iter(iterable)] * n
    return itertools.izip_longest(*args, fillvalue=fillvalue)

# Get scaffolds
scaffolds = [j.rstrip() for j in open(contigs, 'rU')]

# Get the bigger scaffolds first
first = scaffolds[0:240]
# The rest second
rest  = scaffolds[240::]

# write files list
with open("files.list", 'wb') as o:
    flist = glob.glob(indir + "*.bam")
    for fil in sorted(flist):
        o.write(os.path.abspath(fil) + '\n')
o.close()

# Counts for characters
at = 97
ct = 97

# Open parameter file
o_par = open(param, 'wb')

# Process big scaffolds first in groups of 20
for k in grouper(10, first):
    name = "contig-" + chr(at) + chr(ct)
    o_int = os.path.join(intervals, name + ".intervals")
    o_ctg = open(o_int, 'wb')
    o_ctg.write("\n".join([i for i in k if i]) + "\n")
    o_ctg.close

    olog = logs + name + ".log"
    o_fil = os.path.join(odir, "rawINDEL-Q30-" + name + ".vcf")

    o_par.write("{0} -L {1} -I files.list -R {2} {3} -o {4} > {5}\n".format(
      script, o_int, ref, filters, o_fil, olog))

    if ct < 122:
        ct += 1
    else:
        ct = 97
        at += 1

# Process smaller scaffolds now in groups of 100 
for k in grouper(100, rest):
    name = "contig-" + chr(at) + chr(ct)
    o_int = os.path.join(intervals, name + ".intervals")
    o_ctg = open(o_int, 'wb')
    o_ctg.write("\n".join([i for i in k if i]) + "\n")
    o_ctg.close

    olog = logs + name + ".log"
    o_fil = os.path.join(odir, "rawINDEL-Q30-" + name + ".vcf")

    o_par.write("{0} -L {1} -I files.list -R {2} {3} -o {4} > {5}\n".format(
      script, o_int, ref, filters, o_fil, olog))

    if ct < 122:
        ct += 1
    else:
        ct = 97
        at += 1
o_par.close()
