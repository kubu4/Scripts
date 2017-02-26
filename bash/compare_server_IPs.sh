#!/usr/bin/env bash

CURRENT_IP=$(wget -q -O - checkip.dyndns.com | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

OUTLINE

# Determine if file containing IP address exists

# If not, create the file and add the current IP address to the file.

# Else, grab current IP address and store to a diffferent file

# Compare the two files.

# If two files are different, mail IP address to me.
