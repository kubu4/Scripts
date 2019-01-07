#!/bin/bash
## Job Name
#SBATCH --job-name=20181127_oly_maker_genome_annotation
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
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation

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

### Paths to Maker binaries
maker=/gscratch/srlab/programs/maker-2.31.10/bin/maker
gff3_merge=/gscratch/srlab/programs/maker-2.31.10/bin/gff3_merge
fasta_merge=/gscratch/srlab/programs/maker-2.31.10/bin/fasta_merge
maker2zff=/gscratch/srlab/programs/maker-2.31.10/bin/maker2zff
fathom=/gscratch/srlab/programs/maker-2.31.10/exe/snap/fathom
forge=/gscratch/srlab/programs/maker-2.31.10/exe/snap/forge
hmmassembler=/gscratch/srlab/programs/maker-2.31.10/exe/snap/hmm-assembler.pl

### Path to Olympia oyster genome FastA file
oly_genome=/gscratch/srlab/sam/data/O_lurida/oly_genome_assemblies/Olurida_v081/Olurida_v081.fa

### Path to Olympia oyster transcriptome FastA file
oly_transcriptome=/gscratch/srlab/sam/data/O_lurida/oly_transcriptome_assemblies/Olurida_transcriptome_v3.fasta

### Path to Crassotrea gigas NCBI protein FastA
gigas_proteome=/gscratch/srlab/sam/data/C_gigas/gigas_ncbi_protein/GCA_000297895.1_oyster_v9_protein.faa

### Path to Crassostrea virginica NCBI protein FastA
virginica_proteome=/gscratch/srlab/sam/data/C_virginica/virginica_ncbi_protein/GCF_002022765.2_C_virginica-3.0_protein.faa

### Path to concatenated NCBI prteins FastA
gigas_virginica_ncbi_proteomes=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation/gigas_virginica_ncbi_proteomes.fasta

### Path to O.lurida-specific repeat library
oly_repeat_library=/gscratch/srlab/sam/data/O_lurida/Ostrea_lurida_v081-families.fa

## Create Maker control files needed for running Maker
$maker -CTL

## Store path to options control file
maker_opts_file=./maker_opts.ctl

## Create combined proteome FastA file, only if it doesn't already exist.
if [ ! -e gigas_virginica_ncbi_proteomes.fasta ]; then
    touch gigas_virginica_ncbi_proteomes.fasta
    cat "$gigas_proteome" >> gigas_virginica_ncbi_proteomes.fasta
    cat "$virginica_proteome" >> gigas_virginica_ncbi_proteomes.fasta
fi

## Edit options file

### Set paths to O.lurida genome and transcriptome.
### Set path to combined C. gigas and C.virginica proteomes.
## The use of the % symbol sets the delimiter sed uses for arguments.
## Normally, the delimiter that most examples use is a slash "/".
## But, we need to expand the variables into a full path with slashes, which screws up sed.
## Thus, the use of % symbol instead (it could be any character that is NOT present in the expanded variable; doesn't have to be "%").
sed -i "/^genome=/ s% %$oly_genome %" "$maker_opts_file"
sed -i "/^est=/ s% %$oly_transcriptome %" "$maker_opts_file"
sed -i "/^protein=/ s% %$gigas_virginica_ncbi_proteomes %" "$maker_opts_file"
sed -i "/^rmlib=/ s% %$oly_repeat_library %" "$maker_opts_file"
sed -i "/^est2genome=0/ s/est2genome=0/est2genome=1/" "$maker_opts_file"
sed -i "/^protein2genome=0/ s/protein2genome=0/protein2genome=1/" "$maker_opts_file"

## Run Maker
### Specify number of nodes to use.
mpiexec -n 56 $maker

## Merge gffs
${gff3_merge} -d Olurida_v081.maker.output/Olurida_v081_master_datastore_index.log

## GFF with no FastA in footer
${gff3_merge} -n -s -d Olurida_v081.maker.output/Olurida_v081_master_datastore_index.log > Olurida_v081.maker.all.noseqs.gff

## Merge all FastAs
${fasta_merge} -d Olurida_v081.maker.output/Olurida_v081_master_datastore_index.log

## Run SNAP training, round 1
mkdir snap01 && cd snap01
${maker2zff} ../Olurida_v081.all.gff
${fathom} -categorize 1000 genome.ann genome.dna
${fathom} -export 1000 -plus uni.ann uni.dna
${forge} export.ann export.dna
${hmmassembler} genome . > 20181127__oly_snap01.hmm

## Initiate second Maker run.
### Copy initial maker control files and
### - change gene prediction settings to 0 (i.e. don't generate Maker gene predictions)
### - set location of snaphmm file to use for gene prediction
cp ../maker_* .
sed -i "/^est2genome=1/ s/est2genome=1/est2genome=0/" maker_opts.ctl
sed -i "/^protein2genome=1/ s/protein2genome=1/protein2genome=0/" maker_opts.ctl
sed -i "/^snaphmm=/ s% %20181127__oly_snap01.hmm %" maker_opts.ctl

## Run Maker
### Set basename of files and specify number of CPUs to use
mpiexec -n 56 $maker \
-base 20181127_oly_genome_snap01

## Merge gffs
${gff3_merge} -d 20181127_oly_genome_snap01.maker.output/20181127_oly_genome_snap01_master_datastore_index.log

### GFF with no FastA in footer
${gff3_merge} -n -s -d 20181127_oly_genome_snap01.maker.output/20181127_oly_genome_snap01_master_datastore_index.log > 20181127_oly_genome_snap01.all.noseqs.gff

### Merge all FastAs
${fasta_merge} -d 20181127_oly_genome_snap01.maker.output/20181127_oly_genome_snap01_master_datastore_index.log

## Run SNAP training, round 2
cd ..
mkdir snap02 && cd snap02
${maker2zff} ../snap01/20181127_oly_genome_snap01.all.gff
${fathom} -categorize 1000 genome.ann genome.dna
${fathom} -export 1000 -plus uni.ann uni.dna
${forge} export.ann export.dna
${hmmassembler} genome . > 20181127__oly_snap02.hmm

## Initiate third and final Maker run.
### Copy initial maker control files and:
### - change gene prediction settings to 0 (i.e. don't generate Maker gene predictions)
### - set location of snaphmm file to use for gene prediction
cp ../maker_* .
sed -i "/^est2genome=1/ s/est2genome=1/est2genome=0/" maker_opts.ctl
sed -i "/^protein2genome=1/ s/protein2genome=1/protein2genome=0/" maker_opts.ctl
sed -i "/^snaphmm=/ s% %20181127__oly_snap02.hmm %" maker_opts.ctl

## Run Maker
### Set basename of files and specify number of CPUs to use
mpiexec -n 56 $maker \
-base 20181127_oly_genome_snap02

## Merge gffs
${gff3_merge} \
-d 20181127_oly_genome_snap02.maker.output/20181127_oly_genome_snap02_master_datastore_index.log

### GFF with no FastA in footer
{gff3_merge} -n -s -d 20181127_oly_genome_snap02.maker.output/20181127_oly_genome_snap02_master_datastore_index.log > 20181127_oly_genome_snap02.all.noseqs.gff

### Merge all FastAs
${fasta_merge} -d 20181127_oly_genome_snap02.maker.output/20181127_oly_genome_snap02_master_datastore_index.log
