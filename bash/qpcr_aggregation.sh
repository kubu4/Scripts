#!/bin/bash

# Shell script to aggregate and format exported CSV data from BioRad CFX Manager v.3.x.

# Dependencies:
# R script: CFX_Cq_Agg.R (https://github.com/kubu4/Scripts/blob/master/R/CFX_Cq_Agg.R)


# Replace spaces with underscores in filenames

#for file in *.csv; do
# Replace spaces with underscores in filenames
#	mv "$file" "${file// /_}"
#done

# Create new header with qPCR_date as first column name

old_head=",Well,Fluor,Target,Content,Sample,Biological Set Name,Cq,Cq Mean,Cq Std. Dev,Starting Quantity (SQ),Log Starting Quantity,SQ Mean,SQ Std. Dev,Set Point,Well Note
"
new_head="$(awk 'NR==1 { print "qPCR_Date"$0 }' "$old_head")" 
echo "$old_head"
echo "$new_head"

# Pull date from filename
for file in *.csv; do
	OIFS="$IFS"
	IFS="_"
	read -a qpcr_date <<< "${file}"
	qpcr_date="${qpcr_date[1]}"
	echo "$qpcr_date"
	IFS="$OIFS"

# Add qPCR_date header to first column

	
# Add qPCR date to first column
	awk -v var="$qpcr_date" '{ print var$0 }' "$file" > "${file/.csv/.tmp}"

# Append new first column with filename.
	#awk -F, '{$1='$qpcr_date' FS $1;}1' OFS=, "$file"
	#head -1 "$file"
# Run Rscript (CFX_Cq_Agg.R) to combine replicate Cq data on single line
done