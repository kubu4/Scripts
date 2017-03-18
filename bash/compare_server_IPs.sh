#!/usr/bin/env bash


#OUTLINE


# Create the file.

touch ip.txt

wget --quiet --output-document=- checkip.dyndns.com | \
grep --only-matching --extended-regexp "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > current_ip.txt

# Compare the two files.

diff ip.txt current_ip.txt

# If two files are different, mail IP address to me.

case $? in
    1)
        cat current_ip.txt > ip.txt
	echo "this is working"
	cat ip.txt
	cat current_ip.txt
	;;
    0)
esac

