#!/usr/bin/perl

# This script was originally created by Giles Goetz @ the NOAA Northwest Fisheries
# Science Center (NFSC).

# This perl script takes the output file from the bash script: qpcr_aggregation.sh
# The script identifies qPCR replicates and consolidates the Cq value from each replicate
# to a single line. 

use warnings;
use strict;

# Open the file
my $input = shift(@ARGV);
open(my $in, "<", $input);

# Initialize some variables for looping
my $curr_content = "";
my $curr_sample = "";
my $curr_line = "";
my @data = ();

# Set up the first line, need to initialize these to start 
# with the looping. We're basically saving the whole line ($curr_line = <$in>),
# removing any newline characters (chomp($curr_line)), and then splitting the line
# on commas to save each field in an array (@data = split(/,/, $curr_line)).
# This also stores the values in column 6 (Content column - $data[5]) and 
# column 7 (Sample column - $data[7]).
$curr_line = <$in>;
chomp($curr_line);
@data = split(/,/, $curr_line);
$curr_content = $data[5];
$curr_sample = $data[7];

# Loop through every line in the file
while (my $line = <$in>) {
    # removing the line return
    chomp($line);

    # Spliting the columns at each comma
    my @data = split(/,/, $line);

    # Append to current line if Content (column 6) and Sample (column 7) 
    # on one line equals Content and Sample on the next line,
    # otherwise set our looping variables to new ones
    if ($curr_content eq $data[5] && $curr_sample eq $data[7]) {
        $curr_line = $curr_line . "," . $data[9];
    } else {
        # Print what we've saved so far before we reset
        print $curr_line . "\n";

        # Now set everything to new values
        $curr_content = $data[5];
        $curr_sample = $data[7];
        $curr_line = $line;
    }
}

# Need this to print last line otherwise we would never see it.
print $curr_line . "\n";
