#!/bin/sh

# Shell script to aggregate and format exported CSV data from BioRad CFX Manager v.3.x.

# Dependencies:
# R script: CFX_Cq_Agg.R (https://github.com/kubu4/Scripts/blob/master/R/CFX_Cq_Agg.R)

for file in . do
# Remove spaces from filenames
	do mv "$file" ${file// /}
# Add date to first column

# Append new first column with filename.

# Run Rscript (CFX_Cq_Agg.R) to combine replicate Cq data on single line

done