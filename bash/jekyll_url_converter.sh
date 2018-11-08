#!/usr/bin/env bash

# Bash script to fix URLs from old Wordpress site that was converted to markdown via Exitwp program.
# Finds all old URLs matching grep pattern and replaces them with Jekyll format (e.g. YYYY/mm/dd/title.html)

# Take input file and assing to variable
fileName=$1

# Use grep to capture full URL in array, in case multiple links in a file.
## Declare array
declare -a old_url=()

## Capture all exact matches via grep and save to array
old_url=($(grep -o '(http://onsnetwork.org/kubu4/[^)]*/)' "${fileName}"))


# Iterate through array to reformat old URLs to new repo relative paths
# and edit file "in place" with sed.

## Strip off first 29 and last two characters of the URL
## Append .html to end of modified URL.
## Use sed to edit file in place to replace old URLs with new URLs.
for url in "${old_url[@]}"
do
  new_format=$(echo ${url: 29:-2})
  new_link="(${new_format}.html)"
  sed -i.old "s~${url}~${new_link}~g" "${fileName}"
done
