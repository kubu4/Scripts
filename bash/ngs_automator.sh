#Shell script for automatically identifying directories lacking readme.md files
#Creates readme.md files with corresponding path.
#For directories lacking readme.md files, generates readcounts for all FASTQ.gz files
#and appends the name and corresponding read counts to the newly created readme.md files.

#Finds folders lacking readme.md files and stores to variable "no_readme"

no_readme=$(while read i; do echo "$i"; done < <(find "`pwd`" -not -path '*/\.*' -mindepth 1 -type d '!' -exec test -e "{}/readme.md" ';' -print))

#Writes path to readme files in directories lacking readme files.

printf '%s\n' "$no_readme" | sed 's/Volumes\/owl_web/web/' | while IFS= read -r line; do echo "$line" >> "$no_readme"/readme.md; done



#While loop counts the lines in each file and divides them by four. This is performed because
#Illumina sequencing files are composed of four lines per read.
#Format the output (printf) to print the filename, followed by a tab, followed by the readcount.
#The command "tee -a" is used to both print the output to the screen and append the output to the readme.md file.

printf '%s\n' "$no_readme"  | while IFS= read -r line; do linecount=`gunzip -c "$line"/*.gz | wc -l`; readcount=$(($linecount/4)); printf "%s\t%s\n\n" "${line##*/}" "$readcount" >> "$line"/readme.md; done

#Finds folders lacking checksums.md5 files and generates checksums for all files in that directory

while read i; do md5 "$i"/*.gz >> checksums.md5; done < <(find "`pwd`" -not -path '*/\.*' -mindepth 1 -type d '!' -exec test -e "{}/checksums.md5" ';' -print)

