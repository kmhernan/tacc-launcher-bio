#!/bin/bash
#SBATCH -J RA_job
#SBATCH -o RA_job.o%j
#SBATCH -e RA_job.e%j
#SBATCH -N 60
#SBATCH -n 476
#SBATCH -p normal
#SBATCH -t 06:00:00
#SBATCH -A P.hallii_expression

module load launcher
PARAM="bam.param"
EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher

# Launch
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $PARAM

echo "DONE"
date;
