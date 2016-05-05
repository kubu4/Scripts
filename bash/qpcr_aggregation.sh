#!/bin/bash

# Shell script to aggregate and format exported CSV data from BioRad CFX Manager v.3.x.
# This script will:
# - Replace the spaces in the BioRad filenames
# - Replace the header row to accommodate two new fields: qPCR_filename and qPCR_date
# - Concatenate all the files into a single "master" CSV file.


# Replace spaces with underscores in filenames

for file in *.csv; do
	mv "$file" "${file// /_}"
done

# Create new header with qPCR_date as first column name
## Hard-coded value containng the default header from all CFX Manager v.3.x exported CSV files
old_head=",Well,Fluor,Target,Content,Sample,Biological Set Name,Cq,Cq Mean,Cq Std. Dev,Starting Quantity (SQ),Log Starting Quantity,SQ Mean,SQ Std. Dev,Set Point,Well Note
"
echo "$old_head" > old_head.tmp
new_head="$(awk 'NR==1 { print "qPCR_filename,qPCR_Date"$0 }' old_head.tmp)" 
echo "$old_head"
echo "$new_head"


for file in *Quantification*.csv; do
	
	# Pull date from filename
	OIFS="$IFS"
	IFS="_"
	read -a file_array <<< "${file}"
	qpcr_date="${file_array[1]}"
	echo "$qpcr_date"
	IFS="$OIFS"
	
	# Save qpcr filename to variable
	qpcr_filename=$(printf "${file_array[@]:0:4}")
	qpcr_filename="${qpcr_filename// /_}.pcrd"
	echo "$qpcr_filename"
	
	# Remove header to allow for easier data appending.
	awk 'NR>1' "$file" > "${file/.csv/.headless}"
	
	# Add qPCR date to first column and output to .tmp file
	for file1 in *.headless; do
		awk -v var="$qpcr_date" '{ print var$0 }' "$file1" > "${file1/.headless/.tmp}"
		# Add new first column and append filename.
		for file2 in *.tmp; do
			awk -F, -v var="$qpcr_filename" '{$1=var FS $1;}1' OFS=, "$file2" >> master.csv
		done
	done
done

	
# Add header
	sed -i.old "1s/^.*$/$new_head/" master.csv
	rm *.old