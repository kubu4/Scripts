#!/bin/sh

#Shell script to remove Google MP3 DRM (PrivateFrame). Place in top level of music directory.

#Requires eyeD3 program to be installed on computer.

#Touch commands create output files
touch ~/testing/pre_googleDRM.out
touch ~/testing/post_googleDRM.out

#For loop recursively searches for files that contain the word "Google".
#The name of any matching file is written to file.
#Any matching files have the PrivateFrame removed from the file using eyeD3 program.
IFS=$'\n'
for i in $(find . -name '*.mp3')
do
grep Google "$i"
if [ $? -eq 0 ]
then echo "$i" >> ~/testing/pre_googleDRM.out && eyeD3 --remove-frame PRIV "$i"
fi
done


#For loop recursively searches for files that contain the word "Google".
#The name of any matching file is written to file.
IFS=$'\n'
for i in $(find . -name '*.mp3')
do
grep Google "$i"
if [ $? -eq 0 ]
then echo "$i" >> ~/testing/post_googleDRM.out
fi
done

#Uses diff to compare the pre and post PrivateFrame grep results and writes result to file.
#Used to confirm that the Google DRM was successfully removed from files.
diff ~/testing/pre_googleDRM.out ~/testing/post_googleDRM.out > ~/testing/diff_googleDRM.out
