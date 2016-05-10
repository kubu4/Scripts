#!/bin/bash

# Shell script to aggregate and format exported CSV data from BioRad CFX Manager v.3.x.
# This script will:
# - Replace the spaces in the BioRad filenames
# - Replace the header row to accommodate two new fields: qPCR_filename and qPCR_date
# - Append the filename and the qPCR date to the new columns
# - Concatenate all the files into a single "master" CSV file.


# Set final output filename
master_list="qPCR_master_list_messy.csv"

# Replace spaces in filenames with underscores.
for file in *.csv; do
	mv "$file" "${file// /_}"
done

# Create new header with qPCR_date as first column name
## Hard-coded value containing the default header from all CFX Manager v.3.x exported CSV files
old_head=",Well,Fluor,Target,Content,Sample,Biological Set Name,Cq,Cq Mean,Cq Std. Dev,Starting Quantity (SQ),Log Starting Quantity,SQ Mean,SQ Std. Dev,Set Point,Well Note
"
## Write the $old_head contents to a temporary file.
echo "$old_head" > old_head.tmp

## Takes $old_head.tmp as input.
## Use awk to operate on the first line (the only line, in this particular case) of the input file and append two new header
## values (qPCR_filename and qPCR_Date) to the beginning of the rest of the header values.
new_head="$(awk 'NR==1 { print "qPCR_filename,qPCR_Date"$0 }' old_head.tmp)" 
echo "$old_head"
echo "$new_head"


# Remove headers from files, add new columns, fill columns with appropriate data
# for corresponding fields and concatenates all processed files into a single CSV file.
## Takes BioRad CSV files as input.
for file in *Quantification*.csv; do
	
	### Pull date from filename.
	### Create an array ($file_array) using underscore as delimiter (field separator [IFS]).
	OIFS="$IFS"
	IFS="_"
	read -a file_array <<< "${file}"
	
	### Store the value of file_array at index 1.
	qpcr_date="${file_array[1]}"
	echo "$qpcr_date"
	
	### Set IFS back to original (i.e. system default) field separator.
	IFS="$OIFS"
	
	### Save qpcr filename to variable.
	### Slice array from indices 0-4, print them and store in qpcr_filename.
	qpcr_filename=$(printf "${file_array[@]:0:4}")
	
	### Use parameter substitution to replace spaces with underscore, and append .pcrd to contents of variable.
	qpcr_filename="${qpcr_filename// /_}.pcrd"
	echo "$qpcr_filename"
	
	### Remove header to allow for easier data appending.
	### Use awk to capture all records (i.e. rows), except the first row.
	### Use parameter substitution to replace .csv extension of output file with .headless extension.
	awk 'NR>1' "$file" > "${file/.csv/.headless}"
	
	### Add qPCR date to first column of .headless files created in previous step and output to .tmp file
	for file1 in *.headless; do
		
		### Pass bash variable ($qpcr_date) to awk, and append the value to the beginning of all records.
		### Use pareeter substitution to output to filename with .tmp extension.
		awk -v var="$qpcr_date" '{ print var$0 }' "$file1" > "${file1/.headless/.tmp}"
		
		### Add new first column and append filename to .tmp files created in previous step.
		### Pass bash variable ($qpcr_filename) to awk, and append value to new column.
		### Concatenate output to master.csv file.
		for file2 in *.tmp; do
			awk -F, -v var="$qpcr_filename" '{$1=var FS $1;}1' OFS=, "$file2" >> $master_list
		done
	done
done

	
# Add header
## Takes $master_list (.csv file) as input.
## Use sed to edit $master_list "in place" and create a backup file with .old extension (-i.old).
## Sed inserts $new_head above the first line of master.csv and then deletes the backup file.
sed -i.old "1s/^.*$/$new_head/" $master_list
rm *.old
