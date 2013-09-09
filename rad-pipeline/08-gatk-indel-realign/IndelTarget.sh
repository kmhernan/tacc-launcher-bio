#!/bin/bash
#SBATCH -J TARGET_job
#SBATCH -o TARGET_job.o%j
#SBATCH -e TARGET_job.e%j
#SBATCH -N 60
#SBATCH -n 471
#SBATCH -p normal
#SBATCH -t 04:00:00
#SBATCH -A P.hallii_expression

module load launcher
PARAM="targets.param"
EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher

# Launch
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $PARAM

echo "DONE"
date;
