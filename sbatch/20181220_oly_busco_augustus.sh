#!/bin/bash
## Job Name
#SBATCH --job-name=busco
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=2
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20181220_oly_busco_agustus

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing

module load icc_19-ompi_3.1.2

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log

## Establish variables for more readable code
maker_dir=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation/
busco=/gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py
bedtools=/gscratch/srlab/programs/bedtools-2.27.1/bin/bedtools
oly_genome=/gscratch/srlab/sam/data/O_lurida/oly_genome_assemblies/Olurida_v081/Olurida_v081.fa
