#!/bin/bash
## Job Name
#SBATCH --job-name=interproscan
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_interproscan

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

# Variables
interproscan=/gscratch/srlab/programs/interproscan-5.31-70.0/interproscan.sh
maker_prot_fasta=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_id_mapping/20181127_oly_genome_snap02.all.maker.proteins.renamed.fasta

# Run InterProScan 5
## disable-precalc since this requires external database access (which Mox does not allow)
${interproscan} \
--input ${maker_prot_fasta} \
--goterms \
--output-file-base 20180108_oly_maker_proteins_ips \
--disable-precalc
