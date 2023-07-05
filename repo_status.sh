#!/bin/bash

# Given a repositories.txt containing repositories under googleapis org, this script captures 5 things about each repository
# 1. owlbot status (0=inactive, 1=active)
# 2. release-please status (0=inactive, 1=active)
# 3. renovate bot status (0=inactive, 1=active)
# 4. open issues count
# 5. open pull requests count

set -e

language=$1
repositories=$language.txt
code_exists=true
archived_count=0
total_count=0
filename="$language-results.md"
# Define the column headers
echo "# $language" > $language-results.md
echo "| Repository | Open Issues | Open Pull Requests | README.MD updated | About updated | Code Deleted | Public Archived |" >> $language-results.md
echo "|------------|-------------|--------------------|--------------------|--------------------|--------------------|--------------------|" >> $language-results.md

for repository in $(cat $repositories); do

  open_issues_count=$(gh issue list -R googleapis/${repository} -L 100 -s open | wc -l)
  open_pull_requests=$(gh pr list -R googleapis/${repository} -L 100 -s open | wc -l)
  total_count=$((total_count + 1))
  if [[ $language == "python" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.rst)
      if [[ $output_readme == *"This github repository is archived"* ]]; then
         is_present_readme=true
      else
         is_present_readme=false
      fi
  fi

  if [[ $language == "java" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.md)
      if [[ $output_readme == *"library has moved to"* ]]; then
        is_present_readme=true
      else
        is_present_readme=false
      fi
      code_deleted=$(./file_existence.sh ${repository})
  fi

  if [[ $language == "nodejs" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.md)
      if [[ $output_readme == *"REPOSITORY IS DEPRECATED"* ]] || [[ $output_readme == *"REPOSITORY HAS BEEN ARCHIVED"* ]] ; then
        is_present_readme=true
      else
        is_present_readme=false
      fi
  fi

  output_about=$(gh repo view googleapis/${repository} --json description -q '.description')
  if [[ $output_about == *"library has moved"* ]]; then
      is_present_about=true
  else
      is_present_about=false
  fi

  status=$(gh repo view googleapis/${repository} --json isArchived -q '.isArchived')
  if [[ $status == "true" ]]; then
      is_public_archive=true
  else
      is_public_archive=false
  fi

  if [[ "$open_issues_count" -eq 0 && "$open_pull_requests" -eq 0 && "$is_present_readme" == "true" && "$is_present_about" == "true" && "$code_deleted" == "true" && "$is_public_archive" == "true" ]]; then
     echo "| $repository (success) | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $code_deleted | $is_public_archive |" >> $filename
     archived_count=$((archived_count + 1))
  else
     echo "| $repository (failure) | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $code_deleted | $is_public_archive |" >> $filename
  fi

done

temp_file=$(mktemp)
line="$archived_count out of $total_count repositories archived successfully."
echo "$line" > $temp_file
cat $filename >> $temp_file
mv $temp_file $filename
