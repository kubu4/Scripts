#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Jekyll header. It prompts the user
# for a phrase and that phrase is utilized in the name of
# the markdown file that is created.

# Set variables
POST_DATE=$(date '+%Y-%m-%d')

echo "Enter phrase:"
read PHRASE
echo "You entered $PHRASE"

printf "%s\nlayout: post\ntitle: _%s_\ndate: '%s\'\n%s" "---" "$PHRASE" "$POST_DATE"