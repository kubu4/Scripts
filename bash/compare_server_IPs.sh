#!/usr/bin/env bash



current_ip=$(wget --quiet --output-document=- checkip.dyndns.com | grep --only-matching --extended-regexp "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

OUTLINE


# Create the file.

touch current_ip.txt

# Else, grab current IP address and store to a diffferent file

# Compare the two files.

# If two files are different, mail IP address to me.
