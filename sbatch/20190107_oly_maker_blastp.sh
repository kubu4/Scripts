#!/bin/bash
## Job Name
#SBATCH --job-name=blastp
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
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190107_oly_maker_blastp

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing

module load icc_19-ompi_3.1.2

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log


# Add BLAST to system PATH
export PATH=$PATH:/gscratch/srlab/programs/ncbi-blast-2.6.0+/bin
export BLASTDB=/gscratch/srlab/blastdbs/UniProtKB_20181008/

# Define variables

blastp=/gscratch/srlab/programs/ncbi-blast-2.6.0+/bin/blastp
uniprot_db=/gscratch/srlab/blastdbs/UniProtKB_20181008/20181008_uniprot_sprot.fasta
maker_p_fasta=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation/snap02/20181127_oly_genome_snap02.all.maker.proteins.fasta
output=/gscratch/scrubbed/samwhite/outputs/20181220_oly_maker_blastp/20190107_blastp.outfmt6

# Run blastp
${blastp} \
-query ${maker_p_fasta} \
-db ${uniprot_db} \
-out ${output} \
-max_target_seqs 1 \
-evalue 1e-6 \
-outfmt 6 \
-num_threads 28
