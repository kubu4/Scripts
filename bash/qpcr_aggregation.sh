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
## Hard-coded value containng the default header from all CFX Manager v.3.x exported CSV files
old_head=",Well,Fluor,Target,Content,Sample,Biological Set Name,Cq,Cq Mean,Cq Std. Dev,Starting Quantity (SQ),Log Starting Quantity,SQ Mean,SQ Std. Dev,Set Point,Well Note
"
echo "$old_head" > old_head.tmp
new_head="$(awk 'NR==1 { print "qPCR_filename,qPCR_Date"$0 }' old_head.tmp)" 
echo "$old_head"
echo "$new_head"


for file in *.csv; do
	
	# Pull date from filename
	OIFS="$IFS"
	IFS="_"
	read -a qpcr_date <<< "${file}"
	qpcr_date="${qpcr_date[1]}"
	echo "$qpcr_date"
	IFS="$OIFS"
done
echo "$qpcr_date"
# Remove header to allow for easier data appending.

	
# Add qPCR date to first column
	awk -v var="$qpcr_date" '{ print var$0 }' "$file" > "${file/.csv/.tmp}"

# Append new first column with filename.
	#awk -F, '{$1='$qpcr_date' FS $1;}1' OFS=, "$file"
	#head -1 "$file"
	
# Add qPCR_date header to first column
	sed -i.old "1s/^.*$/$new_head/" "$file"
	rm *.old
	
# Run Rscript (CFX_Cq_Agg.R) to combine replicate Cq data on single line
done