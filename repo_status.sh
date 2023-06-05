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

# Define the column headers
echo "# $language" > $language-results.md
echo "| Repository | Open Issues | Open Pull Requests | README.MD updated | About updated | Public Archived |" >> $language-results.md
echo "|------------|-------------|--------------------|--------------------|--------------------|--------------------|" >> $language-results.md

for repository in $(cat $repositories); do

  open_issues_count=$(gh issue list -R googleapis/${repository} -L 100 -s open | wc -l)
  open_pull_requests=$(gh pr list -R googleapis/${repository} -L 100 -s open | wc -l)

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

  echo "| $repository | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $is_public_archive |" >> $language-results.md

done
