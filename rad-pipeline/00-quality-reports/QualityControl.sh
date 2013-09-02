#!/bin/bash
#SBATCH -J GetQFile_job
#SBATCH -o GetQFile_job.o%j
#SBATCH -e GetQFile_job.e%j
#SBATCH -n 476
#SBATCH -p normal
#SBATCH -t 01:00:00
#SBATCH -A P.hallii_expression

module load launcher

CMD="Qual-File.param"

EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $CMD
