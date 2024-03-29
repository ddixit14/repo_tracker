#!/bin/bash

set -e
repo=$1
language=$2

response=$(gh api "/repos/googleapis/$repo/git/trees/main?recursive=true" -q '.tree[]|.path')

for row in $response; do
    echo "$row">>files_in_repo.txt
done

sort -d -o files_in_repo.txt files_in_repo.txt

file_1=files_in_repo.txt

if [[ "$language" == "java" ]] ; then
  file_2=expected-files-java.txt
  elif [[ "$language" == "nodejs" ]] ; then
    grep -vi ".readme-partials.yml" files_in_repo.txt > temp.txt && mv temp.txt files_in_repo.txt
    grep -vi ".readme-partials.yaml" files_in_repo.txt > temp1.txt && mv temp1.txt files_in_repo.txt
    file_2=expected-files-nodejs.txt
  elif [[ "$language" == "python" ]] ; then
    file_2=expected-files-python.txt
fi

# Read the contents of the first file
contents_1=$(cat $file_1)
# echo "files in repo are:" $contents_1
rm files_in_repo.txt
# Read the contents of the second file
contents_2=$(cat $file_2 |sort -d)
#echo "files that should exist:" $contents_2
# Check if the contents of the two files are equal
if [[ "$contents_1" == "$contents_2" ]]; then
 echo "true"
else
 echo "false"
fi
