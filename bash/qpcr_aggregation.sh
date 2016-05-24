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
old_head=",Well,Fluor,Target,Content,Sample,Biological Set Name,Cq,Cq Mean,Cq Std. Dev,Starting Quantity (SQ),Log Starting Quantity,SQ Mean,SQ Std. Dev,Set Point,Well Note"

## Write the $old_head contents to a temporary file.
echo "$old_head" > old_head.tmp

## Takes $old_head.tmp as input.
## Use awk to operate on the first line (the only line, in this particular case) of the input file and append two new header
## values (qPCR_filename and qPCR_Date) to the beginning of the rest of the header values.
new_head="$(awk 'NR==1 { print "qPCR_filename,qPCR_Date"$0 }' old_head.tmp)" 
echo "$old_head"
echo ""
echo "$new_head"

outer=1 # Set outer loop counter.
inner=1 # Set inner loop counter.

# Remove headers from files, add new columns, fill columns with appropriate data
# for corresponding fields and concatenates all processed files into a single CSV file.
## Takes BioRad CSV files as input.
for file in *Quantification*.csv; do
	

	echo "Pass $outer in outer loop."
	echo "---------------------"

	### Pull date from filename.
	### Create an array ($file_array) using underscore as delimiter (field separator [IFS]).
	OIFS="$IFS"
	IFS="_"
	read -a file_array <<< "${file}"
	
	### Store the value of file_array at index 1.
	qpcr_date="${file_array[1]}"
	echo "qPCR Date: $qpcr_date"
	
	### Set IFS back to original (i.e. system default) field separator.
	IFS="$OIFS"
	
	### Save qpcr filename to variable.
	### Parameter expansion/substitution to remove end of .csv filename
	qpcr_filename="${file//_-__Quantification_Cq_Results_0/}"
	echo "Parameter subsitution 1: $qpcr_filename"
	qpcr_filename="${qpcr_filename//.csv/.pcrd}"
	echo "Parameter subsitution 2: $qpcr_filename"

	
	### Remove header to allow for easier data appending.
	### Use awk to capture all records (i.e. rows), except the first row.
	### Use parameter substitution to replace .csv extension of output file with .headless extension.
	awk 'NR>1' "$file" > "${file/.csv/.headless}"
	echo "Pre-headless: $qpcr_date"

	### Add qPCR date to first column of .headless files created in previous step and output to .tmp file
	for file1 in *.headless; do
		echo "Pass $inner in inner loop."
    		let "inner+=1"  # Increment inner loop counter.
		echo "Head in date: $qpcr_date"		
		echo "File1: $file1"
		
	### Pass bash variables ($qpcr_filename, $qpcr_date) to awk, and append the values to the beginning of all records.
		### Use parameter substitution to output to filename with .tmp extension and concatenate output to master .csv file.
		awk -v var1="$qpcr_filename" -v var2="$qpcr_date" '{ print var1","var2$0 }' "$file1" | tee "${file1/.headless/.tmp}" >> "$master_list"
		echo "Head out date: $qpcr_date"
		rm "$file1"
	done	
	let "outer+=1"    # Increment outer loop counter. 
done

	
# Add header
## Takes $master_list (.csv file) as input.
## Use sed to edit $master_list "in place" and create a backup file with .old extension (-i.old).
## Sed inserts $new_head above the first line of $master_list and then deletes the backup file.
sed -i.old "1s/^.*$/$new_head/" "$master_list"
rm *.old
