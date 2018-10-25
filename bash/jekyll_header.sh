#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Jekyll header. It prompts the user
# for a phrase and that phrase is utilized in the name of
# the markdown file that is created.

# To run, copy this file to your desired directory.
# Change to the directory where you just copied this file.
# In a terminal prompt, type:. jekyll_header.sh

# Set variables
post_date=$(date '+%Y-%m-%d')
md_line="---"
layout="layout: post"
title="title: "
date_line="date: "
comments="comments: true"
tags="tags: "
categories="categories: "

# Ask user for input
echo "Enter post title (use no punctuation):"
read post_title
echo "You entered ${post_title}"

echo "Enter tags (space separated)"
read tag_list
echo "You entered ${tag_list}"

echo "Enter categories (space separated)"
read categories_list
echo "You entered ${categories_list}"

# remove spaces from post-title and replace with hyphens
formatted_title=$(echo -ne "${post_title}" | tr [:space:] '-')

# save new filename using post_date and formatted_phrase variables.
new_md_file="$(echo -n "${post_date}"-"${formatted_title}")".md


# prints formatted jekyll header utilizing post_date and user-entered phrase.
# writes contents to new_md_file
printf "%s\n" \
"${md_line}" "${layout}" "${title}${post_title}" "${date_line}'${post_date}'" "${tags}${tag_list}" "${categories}${categories_list}" "${md_line}" >> \
"${new_md_file}"
