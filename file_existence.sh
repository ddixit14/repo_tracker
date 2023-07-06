#!/bin/bash

set -e
repo=$1
language=$2

response=$(gh api "/repos/googleapis/$repo/git/trees/main?recursive=true" -q '.tree[]|.path')

for row in $response; do
    echo "$row">>files_in_repo.txt
done

sort -o files_in_repo.txt files_in_repo.txt

file_1=files_in_repo.txt

if [[ "$language" == "java" ]] ; then
  file_2=expected-files-java.txt
  elif [[ "$language" == "nodejs" ]] ; then
    file_2=expected-files-nodejs.txt
  elif [[ "$language" == "python" ]] ; then
    file_2=expected-files-python.txt
fi

# Read the contents of the first file
contents_1=$(cat $file_1)
#echo "files in repo are:" $contents_1
rm files_in_repo.txt
# Read the contents of the second file
contents_2=$(cat $file_2)
#echo "files that should exist:" $contents_2
# Check if the contents of the two files are equal
if [[ "$contents_1" == "$contents_2" ]]; then
  echo "true"
else
  echo "false"
fi
