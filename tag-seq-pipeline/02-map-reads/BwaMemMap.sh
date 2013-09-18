#!/bin/bash
#SBATCH -J full_map
#SBATCH -o full_map.o%j
#SBATCH -e full_map.e%j
#SBATCH -N 69
#SBATCH -n 274
#SBATCH -p normal
#SBATCH -t 05:00:00
#SBATCH -A switchgrass_454

module load launcher
CMD="Shrimp-File.param"

EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $CMD

echo "DONE";
date;
