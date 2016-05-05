#!/bin/bash

# Shell script to aggregate and format exported CSV data from BioRad CFX Manager v.3.x.

# Dependencies:
# R script: CFX_Cq_Agg.R (https://github.com/kubu4/Scripts/blob/master/R/CFX_Cq_Agg.R)


# Replace spaces with underscores in filenames
for file in *.csv; do
# Replace spaces with underscores in filenames
	mv "$file" "${file// /_}"
	
# Pull date from filename
	OIFS="$IFS"
	IFS="_"
	read -a qpcr_date <<< "${file}"
	qpcr_date="${qpcr_date[1]}"
	echo "$qpcr_date"
	IFS="$OIFS"

# Add date to first column
	#awk -F, '{$1=1 FS $1;}1' OFS=,

# Append new first column with filename.

# Run Rscript (CFX_Cq_Agg.R) to combine replicate Cq data on single line
done