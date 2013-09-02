#!/bin/bash
#SBATCH -J filter_job
#SBATCH -o filter_job.o%j
#SBATCH -e filter_job.e%j
#SBATCH -n 323
#SBATCH -p normal
#SBATCH -t 01:00:00
#SBATCH -A P.hallii_expression

module load launcher
CMD="Filter-File.param"

EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $CMD

echo "DONE";
date;
