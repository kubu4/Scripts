#!/bin/bash

#Shell script to backup lab notebook hosted on onsnetwork.org
#for offline viewing and copy notebook to lab server.

#Change to working directory.

cd /home/samb/notebook_backup/sam

##If changing directory fails (exit status [$?] does NOT equal 0), exit script.

if [ $? -ne 0 ]
then echo "Couldn't change to desired directory. Make sure target directory exists before executing script."
fi

#Download website with all necessary files for offline viewing.
#Reject possibly large files (.zip, .gz, .fastq, .fa, .fasta, .bam, .sam, .gff
#.gtf, etc.). Specify allowable domains to download linked content
#(e.g. dropbox.com, google docs, etc.).

wget --user-agent mozilla --adjust-extension --mirror --span-hosts --convert-links \
--page-requisites \
--reject *.[BbSs][Aa][Mm],*.[Ff][Aa]*,*.zip,*.gz,*.[Tt][Aa][Bb]*,*.txt,*.[Gg]*[Ff],*.goa* \
--no-parent -e robots=off --wait=1 --random-wait --limit-rate=100m \
--domains=onsnetwork.org,eagle.fish.washington.edu,docs.google.com,\
googleusercontent.com,dl.dropbox.com \
http://onsnetwork.org/sjwfriedmanlab/

#Remove string appended to end of Dropbox files
find /home/samb/notebook_backup/sam -type f -name '*?dl=0' | while read f; do mv "$f" "${f//\?dl=0}"; done

#Mounting the lab server requires the Linux "cifs-utils" package, which is not installed by default on 
#Ubuntu.

#Check for installation of cifs-utils. Looks to see if cifs-utils is installed.
#If it is not, then acquire the package. This is only
#necessary the first time this script is run on a new system.

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' cifs-utils | grep "install ok installed")
echo Checking for cifs-utils: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "No cifs-utils. Setting up cifs-utils."
  apt-get --force-yes --yes install cifs-utils
fi


#Set variable with today's date and append notebook owner name.
#Uncomment (i.e. remove #) next line if appending date/name to backup is desired.
#SAM_NOTEBOOK=$(date '+%Y%m%d')_sam

#Source (i.e. load into memory) credentials file for mounting server
#Credentials file contains username/password for lab server.

. /home/samb/.b_or_d_mount_creds

#Verify server is mounted.
#Look for Notebook_backups directory on server.

find /mnt -maxdepth 1 -type d -name 'backupordie'

#If the directory is not found (i.e. exit status [$?] equals 1), then create
#the directory and 
#mount "lab" share of the backupordie server.
#Utilizes username/password variables that were sourced from credentials file.

if [ $? -eq 1 ]
then mkdir /mnt/backupordie
fi

mount -t cifs -o username="$user",password="$pass" \
//backupordie.fish.washington.edu/lab /mnt/backupordie/



#Copy downloaded notebook to Sam's notebook backups folder on lab server.
#Redirects stderror to an error file for troubleshooting
cp -rf /home/samb/notebook_backup/sam/. /mnt/backupordie/Notebook_backups/sam/onsnetwork 2> /home/samb/notebook_backup/error.file

#If copy fails (exit status [$?] does NOT equal 0), exit script.
if [ $? -ne 0 ]
then echo "copy command failed. See error log at /home/samb/notebook_backup/error.file"
fi

#Commit version using Git and timestamp variable for commit message
#git commit -a -m "$SAM_NOTEBOOK"



