#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Jekyll header. It prompts the user
# for a phrase and that phrase is utilized in the name of
# the markdown file that is created.

# Set variables
POST_DATE=$(date '+%Y-%m-%d')
NEW_MD_FILE="$(echo -n "${POST_DATE}"-"${FORMATTED_PHRASE}")".md
MD_LINE="---"
LAYOUT="layout: post"
TITLE="title: "
DATE_LINE="date: "

#Ask user for input
echo "Enter phrase:"
read PHRASE
echo "You entered $PHRASE"

#Remove spaces from PHRASE and replace with hyphens

FORMATTED_PHRASE="$(echo -ne "${PHRASE}" | tr [:space:] '-')"

echo "$FORMATTED_PHRASE"
#Create new file
touch "$NEW_MD_FILE"


# Prints formatted Jekyll header utilizing POST_DATE and user-entered PHRASE.
printf "%s\n%s\n%s_%s_\n%s'%s\'\n%s\n" "$MD_LINE" "$LAYOUT" "$TITLE" "$PHRASE" "$DATE_LINE" "$POST_DATE" "$MD_LINE" >> \
$NEW_MD_FILE

cat $NEW_MD_FILE

