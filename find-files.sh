#!/bin/bash

# Given a repositories.txt containing repositories under googleapis org, this script captures 5 things about each repository
# 1. owlbot status (0=inactive, 1=active)
# 2. release-please status (0=inactive, 1=active)
# 3. renovate bot status (0=inactive, 1=active)
# 4. open issues count
# 5. open pull requests count

set +x

language=$1
repositories=$language.txt

# File to search for
search_file=".github/release-please.yml"

for repository in $(cat $repositories); do

  echo $repository
  response=$(gh api "/repos/googleapis/$repository/git/trees/main?recursive=true" -q '.tree[]|.path')
  echo $response
   if echo "$response" | grep -q "$search_file"; then
      echo "$repository: '$search_file' exists in repository:"
    else
      echo "File '$search_file' does not exist in repository: $repository">>file_search.txt
    fi
  done