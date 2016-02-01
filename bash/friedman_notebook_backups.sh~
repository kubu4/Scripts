#!/bin/bash

#Shell script to backup lab notebook hosted on onsnetwork.org
#for offline viewing and copy notebook to lab server.

#Download website with all necessary files for offline viewing.
#Reject possibly large files (.zip, .gz, .fastq, .fa, .fasta, .bam, .sam, .gff
#.gtf, etc.). Specify allowable domains to download linked content
#(e.g. dropbox.com, google docs, etc.).
wget --user-agent mozilla --adjust-extension --mirror --span-hosts --convert-links \
--page-requisites \
--reject *.[BbSs][Aa][Mm],*.[Ff][Aa]*,*.zip,*.gz,*.[Tt][Aa][Bb]*,*.txt,*.[Gg]*[Ff],*.goa* \
--no-parent -e robots=off --wait=1 --random-wait --limit-rate=100m \
--domains=onsnetwork.org,eagle.fish.washington.edu,docs.google.com,\
googleusercontent.com,www.dropbox.com,dl.dropbox.com \
http://onsnetwork.org/sjwfriedmanlab/


#Mounting the lab server requires the Linux "cifs-utils" package, which is not installed by default on 
#Ubuntu.

#Check for installation of cifs-utils. Looks to see if cifs-utils is installed.
#If it is not (exit status [$?] equals 1), then acquire the package. This is only
#necessary the first time this script is run on a new system.
dpkg -s cifs-utils

if [ $? -eq 1 ]
then apt-get install cifs-utils
fi

#Set variable with today's date and append notebook owner name.
#Uncomment (i.e. remove #) next line if appending date/name to backup is desired.
#SAM_NOTEBOOK=$(date '+%Y%m%d')_sam

#Source (i.e. load into memory) credentials file for mounting server
#Credentials file contains username/password for lab server.
. ~/.b_or_d_mount_creds

#Verify mountpoint (i.e. directory) is present.
#Look for mountpoint directory.
find /mnt -maxdepth 1 -type d -name 'backupordie'

#If the directory does not exist (i.e. exit status [$?] equals 1), then create
#the directory.
if [ $? -eq 1 ]
then sudo mkdir /mnt/backupordie
fi

#Mount "lab" share of the backupordie server.
#Utilizes username/password variables that were sourced from credentials file.
mount -t cifs -o username="$user",password="$pass" \
//backupordie.fish.washington.edu/lab /mnt/backupordie/

#Change to Sam's notebook backups folder.
cd /mnt/backupordie/Notebook_backups/sam

#If change directory fails (exit status [$?] equals 1), exit script.
if [ $? -eq 1 ]
then exit
fi

#Commit version using Git and timestamp variable for commit message
#git commit -a -m "$SAM_NOTEBOOK"



