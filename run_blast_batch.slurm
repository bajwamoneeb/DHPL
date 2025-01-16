#!/bin/bash
#SBATCH --job-name=blast_batch

#SBATCH --output=blast_batch_output_%j.txt
#SBATCH --error=blast_batch_error_%j.txt
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=16
#SBATCH --time=150:00:00

# Change directory to the script location
cd /home/mbajwa

# Run the Python script
python3 flu_segment_QC.py
