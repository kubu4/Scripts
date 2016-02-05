#Finds folders lacking readme.md files, creates them, and writes current directory path to readme.md file
while read i; do echo "$i" > "$i"/readme.md; done < <(find "`pwd`" -not -path '*/\.*' -mindepth 1 -type d '!' -exec test -e "{}/readme.md" ';' -print | sed 's/Volumes\/owl_web/web/')

#Finds folders lacking checksums.md5 files and generates checksums for all files in that directory
while read i; do md5 "$i"/*.gz >> checksums.md5; done < <(find "`pwd`" -not -path '*/\.*' -mindepth 1 -type d '!' -exec test -e "{}/checksums.md5" ';' -print)