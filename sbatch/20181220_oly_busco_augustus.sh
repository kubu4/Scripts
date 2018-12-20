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
bedtools=/gscratch/srlab/programs/bedtools-2.27.1/bin/bedtools
busco=/gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py
busco_db=/gscratch/srlab/sam/data/databases/BUSCO/eukaryota_odb9
maker_dir=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation
oly_genome=/gscratch/srlab/sam/data/O_lurida/oly_genome_assemblies/Olurida_v081/Olurida_v081.fa


# Subset transcripts and include +/- 1000bp on each side.
## Reduces amount of data used for training - don't need crazy amounts to properly train gene models
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ${maker_dir}/Olurida_v081.maker.all.noseqs.gff | \
awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | \
${bedtools} getfasta -fi ${oly_genome} \
-bed - \
-fo Olurida_v081.all.maker.transcripts1000.fasta

cp Olurida_v081.all.maker.transcripts1000.fasta ${maker_dir}


# Run BUSCO/Augustus training
${busco} \
--in Olurida_v081.all.maker.transcripts1000.fasta \
--out  Olurida_maker_busco \
--lineage_path ${busco_db} \
--mode genome \
--cpu 56 \
--long \
--species human \
--tarzip \
--augustus_parameters='--progress=true'
