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
open_issues_stat_count=0
open_pr_stat_count=0
readme_stat_count=0
about_stat_count=0
code_deleted_stat_count=0
archived_stat_count=0
total_count=0
desired_count=0
filename="$language-results.md"

# Define the column headers
echo "# $language" > $language-results.md
echo "| Repository | Open Issues | Open Pull Requests | README.MD updated | About updated | Code Deleted | Public Archived |" >> $language-results.md
echo "|------------|-------------|--------------------|--------------------|--------------------|--------------------|--------------------|" >> $language-results.md

for repository in $(cat $repositories); do

  total_count=$((total_count + 1))

  open_issues_count=$(gh issue list -R googleapis/${repository} -L 100 -s open | wc -l)
  if [[ "$open_issues_count" -eq 0 ]] ; then
    open_issues_stat_count=$((open_issues_stat_count + 1))
  fi

  open_pull_requests=$(gh pr list -R googleapis/${repository} -L 100 -s open | wc -l)
  if [[ "$open_pull_requests" -eq 0 ]] ; then
    open_pr_stat_count=$((open_pr_stat_count + 1))
  fi

  if [[ $language == "python" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.rst)
      if [[ $output_readme == *"This github repository is archived"* ]]; then
         is_present_readme=true
         readme_stat_count=$((readme_stat_count + 1))
      else
         is_present_readme=false
      fi
      code_deleted=$(./file_existence.sh ${repository} $language)
      if [[ "$code_deleted" == "true" ]] ; then
        code_deleted_stat_count=$((code_deleted_stat_count + 1))
      fi
  fi

  if [[ $language == "java" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.md)
      if [[ $output_readme == *"library has moved to"* ]]; then
        is_present_readme=true
        readme_stat_count=$((readme_stat_count + 1))
      else
        is_present_readme=false
      fi
      code_deleted=$(./file_existence.sh ${repository} $language)
      if [[ "$code_deleted" == "true" ]] ; then
        code_deleted_stat_count=$((code_deleted_stat_count + 1))
      fi
  fi

  if [[ $language == "nodejs" ]]; then
      output_readme=$(curl -s https://raw.githubusercontent.com/googleapis/${repository}/main/README.md)
      if [[ $output_readme == *"REPOSITORY IS DEPRECATED"* ]] || [[ $output_readme == *"REPOSITORY HAS BEEN ARCHIVED"* ]] ; then
        is_present_readme=true
        readme_stat_count=$((readme_stat_count + 1))
      else
        is_present_readme=false
      fi
      code_deleted=$(./file_existence.sh ${repository} $language)
      if [[ "$code_deleted" == "true" ]] ; then
        code_deleted_stat_count=$((code_deleted_stat_count + 1))
      fi
  fi

  output_about=$(gh repo view googleapis/${repository} --json description -q '.description')
  if [[ $output_about == *"library has moved"* ]]; then
      is_present_about=true
      about_stat_count=$((about_stat_count + 1))
  else
      is_present_about=false
  fi

  status=$(gh repo view googleapis/${repository} --json isArchived -q '.isArchived')
  if [[ $status == "true" ]]; then
      is_public_archive=true
      archived_stat_count=$((archived_stat_count + 1))
  else
      is_public_archive=false
  fi

  if [[ "$open_issues_count" -eq 0 && "$open_pull_requests" -eq 0 && "$is_present_readme" == "true" && "$is_present_about" == "true" && "$code_deleted" == "true" && "$is_public_archive" == "true" ]]; then
     echo "| $repository (success) | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $code_deleted | $is_public_archive |" >> $filename
     desired_count=$((desired_count + 1))
  else
     echo "| $repository (failure) | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $code_deleted | $is_public_archive |" >> $filename
  fi

done

temp_file=$(mktemp)
line1="Repositories with desirable state:$desired_count/$total_count"
line2="- Zero open issues: $open_issues_stat_count repos"
line3="- Zero pull requests: $open_pr_stat_count repos"
line4="- README.md updated $readme_stat_count repos"
line5="- About updated $about_stat_count repos"
line6="- Code Deleted $code_deleted_stat_count repos"
line7="Repositories with desirable state : $desired_count/$total_count"
echo "$line1" >> $temp_file
echo "$line2" >> $temp_file
echo "$line3" >> $temp_file
echo "$line4" >> $temp_file
echo "$line5" >> $temp_file
echo "$line6" >> $temp_file
echo "$line7" >> $temp_file
cat $filename >> $temp_file
mv $temp_file $filename
