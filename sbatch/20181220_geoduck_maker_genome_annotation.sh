#!/bin/bash
## Job Name
#SBATCH --job-name=2018120_geoduck_maker_genome_annotation
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
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20181220_geoduck_maker_genome_annotation

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

# Add BLAST to system PATH
export PATH=$PATH:/gscratch/srlab/programs/ncbi-blast-2.6.0+/bin
export BLASTDB=/gscratch/srlab/blastdbs/UniProtKB_20181008/


## Establish variables for more readable code

work_dir=$(pwd)

### Paths to Maker binaries

maker=/gscratch/srlab/programs/maker-2.31.10/bin/maker
gff3_merge=/gscratch/srlab/programs/maker-2.31.10/bin/gff3_merge
maker2zff=/gscratch/srlab/programs/maker-2.31.10/bin/maker2zff
fathom=/gscratch/srlab/programs/maker-2.31.10/exe/snap/fathom
forge=/gscratch/srlab/programs/maker-2.31.10/exe/snap/forge
hmmassembler=/gscratch/srlab/programs/maker-2.31.10/exe/snap/hmm-assembler.pl
fasta_merge=/gscratch/srlab/programs/maker-2.31.10/bin/fasta_merge
map_ids=/gscratch/srlab/programs/maker-2.31.10/bin/maker_map_ids
map_gff_ids=/gscratch/srlab/programs/maker-2.31.10/bin/map_gff_ids
map_fasta_ids=/gscratch/srlab/programs/maker-2.31.10/bin/map_fasta_ids


blastp_dir=${wd}/blastp_annotation
maker_blastp=${wd}/blastp_annotation/20181220_blastp.outfmt6
maker_prot_fasta=${wd}/snap02/20181220_geoduck_snap02.all.maker.proteins.fasta
maker_transcripts_fasta=${wd}/snap02/20181220_geoduck_snap02.all.maker.transcripts.fasta
snap02_gff=${wd}/snap02/20181220_geoduck_snap02.all.gff
maker_ips=${wd}/interproscan_annotation

## Path to blastp
blastp=/gscratch/srlab/programs/ncbi-blast-2.6.0+/bin/blastp

## Path to InterProScan5
interproscan=/gscratch/srlab/programs/interproscan-5.31-70.0/interproscan.sh

## Store path to options control file
maker_opts_file=./maker_opts.ctl

### Path to genome FastA file
genome=/gscratch/srlab/sam/data/P_generosa/generosa_genomes/Pgenerosa_v070.fa

### Path to transcriptome FastA file
transcriptome=/gscratch/srlab/sam/data/P_generosa/generosa_transcriptomes/20180827_trinity_geoduck.fasta

### Path to Crassotrea gigas NCBI protein FastA
gigas_proteome=/gscratch/srlab/sam/data/C_gigas/gigas_ncbi_protein/GCA_000297895.1_oyster_v9_protein.faa

### Path to Crassostrea virginica NCBI protein FastA
virginica_proteome=/gscratch/srlab/sam/data/C_virginica/virginica_ncbi_protein/GCF_002022765.2_C_virginica-3.0_protein.faa

### Path to Panopea generosa TransDecoder protein FastA
panopea_td_proteome=/gscratch/srlab/sam/data/P_generosa/generosa_proteomes/20180827_trinity_geoduck.fasta.transdecoder.pep

### Path to concatenated NCBI prteins FastA
combined_proteomes=/gscratch/scrubbed/samwhite/outputs/20181127_oly_maker_genome_annotation/gigas_virginica_ncbi_proteomes.fasta

### Path to P.generosa-specific repeat library
repeat_library=/gscratch/srlab/sam/data/P_generosa/generosa_repeats/Pgenerosa_v070-families.fa

### Path to SwissProt database
sp_db=/gscratch/srlab/blastdbs/UniProtKB_20181008/20181008_uniprot_sprot.fasta

## Make directories
mkdir blastp_annotation
mkdir interproscan_annotation


## Create Maker control files needed for running Maker, only if it doesn't already exist and then edit it.
### Edit options file
### Set paths to P.generosa genome and transcriptome.
### Set path to combined C. gigas, C.virginica, P.generosa proteomes.
### The use of the % symbol sets the delimiter sed uses for arguments.
### Normally, the delimiter that most examples use is a slash "/".
### But, we need to expand the variables into a full path with slashes, which screws up sed.
### Thus, the use of % symbol instead (it could be any character that is NOT present in the expanded variable; doesn't have to be "%").
if [ ! -e maker_opts.ctl ]; then
  $maker -CTL
  sed -i "/^genome=/ s% %$genome %" "$maker_opts_file"
  sed -i "/^est=/ s% %$transcriptome %" "$maker_opts_file"
  sed -i "/^protein=/ s% %$gigas_virginica_ncbi_proteomes %" "$maker_opts_file"
  sed -i "/^rmlib=/ s% %$repeat_library %" "$maker_opts_file"
  sed -i "/^est2genome=0/ s/est2genome=0/est2genome=1/" "$maker_opts_file"
  sed -i "/^protein2genome=0/ s/protein2genome=0/protein2genome=1/" "$maker_opts_file"
fi

## Create combined proteome FastA file, only if it doesn't already exist.
if [ ! -e combined_proteomes.fasta ]; then
    touch combined_proteomes.fasta
    cat "$gigas_proteome" >> combined_proteomes.fasta
    cat "$virginica_proteome" >> combined_proteomes.fasta
    cat "$panopea_td_proteome" >> combined_proteomes.fasta
fi



## Run Maker
### Specify number of nodes to use.
mpiexec -n 56 $maker

## Merge gffs
${gff3_merge} -d Pgenerosa_v70.maker.output/Pgenerosa_v70_master_datastore_index.log

## GFF with no FastA in footer
${gff3_merge} -n -s -d Pgenerosa_v70.maker.output/Pgenerosa_v70_master_datastore_index.log > Pgenerosa_v70.maker.all.noseqs.gff

## Merge all FastAs
${fasta_merge} -d Pgenerosa_v70.maker.output/Pgenerosa_v70_master_datastore_index.log

## Extract GFF alignments for use in subsequent MAKER rounds
### Transcript alignments
awk '{ if ($2 == "est2genome") print $0 }' Pgenerosa_v70.maker.all.noseqs.gff > Pgenerosa_v70.maker.all.noseqs.est2genome.gff
### Protein alignments
awk '{ if ($2 == "protein2genome") print $0 }' Pgenerosa_v70.maker.all.noseqs.gff > Pgenerosa_v70.maker.all.noseqs.protein2genome.gff
### Repeat alignments
awk '{ if ($2 ~ "repeat") print $0 }' Pgenerosa_v70.maker.all.noseqs.gff > Pgenerosa_v70.maker.all.noseqs.repeats.gff

## Run SNAP training, round 1
mkdir snap01 && cd snap01
${maker2zff} ../Pgenerosa_v70.all.gff
${fathom} -categorize 1000 genome.ann genome.dna
${fathom} -export 1000 -plus uni.ann uni.dna
${forge} export.ann export.dna
${hmmassembler} genome . > 20181220_geoduck_snap01.hmm

## Initiate second Maker run.
### Copy initial maker control files and
### - change gene prediction settings to 0 (i.e. don't generate Maker gene predictions)
### - use GFF subsets generated in first round of MAKER
### - set location of snaphmm file to use for gene prediction
### Percent symbols used below are the sed delimiters, instead of the default "/",
### due to the need to use file paths.
if [ ! -e maker_opts.ctl ]; then
  $maker -CTL
  sed -i "/^genome=/ s% %$genome %" maker_opts.ctl
  sed -i "/^est2genome=1/ s/est2genome=1/est2genome=0/" maker_opts.ctl
  sed -i "/^protein2genome=1/ s/protein2genome=1/protein2genome=0/" maker_opts.ctl
  sed -i "/^est_gff=/ s% %../Pgenerosa_v70.maker.all.noseqs.est2genome.gff %" maker_opts.ctl
  sed -i "/^protein_gff=/ s% %../Pgenerosa_v70.maker.all.noseqs.protein2genome.gff %" maker_opts.ctl
  sed -i "/^rm_gff=/ s% %../Pgenerosa_v70.maker.all.noseqs.repeats.gff %" maker_opts.ctl
  sed -i "/^snaphmm=/ s% %20181220_geoduck_snap01.hmm %" maker_opts.ctl
fi

## Run Maker
### Set basename of files and specify number of CPUs to use
mpiexec -n 56 $maker \
-base 20181220_geoduck_snap01

## Merge gffs
${gff3_merge} -d 20181220_geoduck_snap01.maker.output/20181220_geoduck_snap01_master_datastore_index.log

## GFF with no FastA in footer
${gff3_merge} -n -s -d 20181220_geoduck_snap01.maker.output/20181220_geoduck_snap01_master_datastore_index.log > 20181220_geoduck_snap01.maker.all.noseqs.gff

## Extract GFF alignments for use in subsequent MAKER rounds
### Transcript alignments
awk '{ if ($2 == "est2genome") print $0 }' 20181220_geoduck_snap01.maker.all.noseqs.gff > 20181220_geoduck_snap01.maker.all.noseqs.est2genome.gff
### Protein alignments
awk '{ if ($2 == "protein2genome") print $0 }' 20181220_geoduck_snap01.maker.all.noseqs.gff > 20181220_geoduck_snap01.maker.all.noseqs.protein2genome.gff
### Repeat alignments
awk '{ if ($2 ~ "repeat") print $0 }' 20181220_geoduck_snap01.maker.all.noseqs.gff > 20181220_geoduck_snap01.maker.all.noseqs.repeats.gff

## Run SNAP training, round 2
cd ..
mkdir snap02 && cd snap02
${maker2zff} ../snap01/20181220_geoduck_snap01.all.gff
${fathom} -categorize 1000 genome.ann genome.dna
${fathom} -export 1000 -plus uni.ann uni.dna
${forge} export.ann export.dna
${hmmassembler} genome . > 20181220_geoduck_snap02.hmm

## Initiate third and final Maker run.
### Copy initial maker control files and:
### - change gene prediction settings to 0 (i.e. don't generate Maker gene predictions)
### - use GFF subsets generated in first round of SNAP
### - set location of snaphmm file to use for gene prediction.
### Percent symbols used below are the sed delimiters, instead of the default "/",
### due to the need to use file paths.
if [ ! -e maker_opts.ctl ]; then
  $maker -CTL
  sed -i "/^genome=/ s% %$genome %" maker_opts.ctl
  sed -i "/^est2genome=1/ s/est2genome=1/est2genome=0/" maker_opts.ctl
  sed -i "/^protein2genome=1/ s/protein2genome=1/protein2genome=0/" maker_opts.ctl
  sed -i "/^est_gff=/ s% %../20181220_geoduck_snap01.maker.all.noseqs.est2genome.gff %" maker_opts.ctl
  sed -i "/^protein_gff=/ s% %../20181220_geoduck_snap01.maker.all.noseqs.protein2genome.gff %" maker_opts.ctl
  sed -i "/^rm_gff=/ s% %../20181220_geoduck_snap01.maker.all.noseqs.repeats.gff %" maker_opts.ctl
  sed -i "/^snaphmm=/ s% %20181220_geoduck_snap02.hmm %" maker_opts.ctl
fi

## Run Maker
### Set basename of files and specify number of CPUs to use
mpiexec -n 56 $maker \
-base 20181220_geoduck_snap02

## Merge gffs
${gff3_merge} \
-d 20181220_geoduck_snap02.maker.output/20181220_geoduck_snap02_master_datastore_index.log

## Merge FastAs
${fasta_merge} \
-d 20181220_geoduck_snap02.maker.output/20181220_geoduck_snap02_master_datastore_index.log


# Run InterProScan 5
## disable-precalc since this requires external database access (which Mox does not allow)
cd ${interproscan_annotation}

${interproscan} \
--input ${maker_prot_fasta} \
--goterms \
--disable-precalc

# Run BLASTp
cd ${blastp_annotation}

${blastp} \
-query ${maker_prot_fasta} \
-db ${sp_db} \
-out ${maker_blastp} \
-max_target_seqs 1 \
-evalue 1e-6 \
-outfmt 6 \
-num_threads 28
