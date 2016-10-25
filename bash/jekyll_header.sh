#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Jekyll header. It prompts the user
# for a phrase and that phrase is utilized in the name of
# the markdown file that is created.

# Set variables
POST_DATE=$(date '+%Y-%m-%d')
NEW_MD_FILE=$POST_DATE-"$PHRASE".md

echo "Enter phrase:"
read PHRASE
echo "You entered $PHRASE"

#Create new file and replace any spaces with hyphens
touch "$NEW_MD_FILE"

mv "$NEW_MD_FILE" ${NEW_MD_FILE// /-}

# Prints formatted Jekyll header utilizing POST_DATE and user-entered PHRASE.
printf "%s\nlayout: post\ntitle: _%s_\ndate: '%s\'\n%s" "---" "$PHRASE" "$POST_DATE"

