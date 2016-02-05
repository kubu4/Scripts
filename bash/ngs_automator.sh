
#Finds folders lacking readme.md files, creates them, and writes current directory path to readme.md file
while read i; do echo "$i"; done < <(find "`pwd`" -not -path '*/\.*' -mindepth 1 -type d '!' -exec test -e "{}/readme.md" ';' -print | sed 's/Volumes\/owl_web/owl\/web/')