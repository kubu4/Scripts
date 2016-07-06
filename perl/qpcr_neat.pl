#!/usr/bin/perl

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
# with the looping. We're basically saving the whole line
# as well as what is stored in columns 6 (Content column) and 7 (Sample column).
$curr_line = <$in>;
chomp($curr_line);
@data = split(/,/, $curr_line);
$curr_content = $data[5];
$curr_sample = $data[6];

# Loop through every line in the file
while (my $line = <$in>) {
    # removing the line return
    chomp($line);

    # Spliting the columns at each comma
    my @data = split(/,/, $line);

    # Append to current line if Content (column 6) and Sample (column 7) 
    # on one line equals Content and Sample on the next line,
    # otherwise set our looping variables to new ones
    if ($curr_content eq $data[5] && $curr_sample eq $data[6]) {
        $curr_line = $curr_line . "," . $data[8];
    } else {
        # Print what we've saved sofar before we reset
        print $curr_line . "\n";

        # Now set everything to new values
        $curr_content = $data[5];
        $curr_sample = $data[6];
        $curr_line = $line;
    }
}

# Need this to print last line otherwise we would never see it.
print $curr_line . "\n";
