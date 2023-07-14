#!/bin/bash

# Given a repositories.txt containing repositories under googleapis org, this script captures 5 things about each repository
# 1. owlbot status (0=inactive, 1=active)
# 2. release-please status (0=inactive, 1=active)
# 3. renovate bot status (0=inactive, 1=active)
# 4. open issues count
# 5. open pull requests count

set -e

# java, python, or nodejs
language=$1
repositories=$language.txt
code_exists=true
open_issues_stat_count=0
open_pr_stat_count=0
readme_stat_count=0
about_stat_count=0
zero_document_reference_count=0
code_deleted_stat_count=0
archived_stat_count=0
total_count=0
desired_count=0
filename="$language-results.md"
if [ -n "${TEST_REPOS}" ]; then
  # For testing, use a shorter file
  repositories="${TEST_REPOS}"
  filename="$language-test-results.md"
fi



# Loads document reference count
# document_reference_count.tsv is manually updated
declare -A document_count
while IFS=$'\t' read -r key document_url file
do
  document_count["$key"]=$((document_count["$key"] + 1))
done < document_reference_count.tsv


# Define the column headers
echo "### Repository state" > $filename
echo "| Repository | Open Issues | Open Pull Requests | README.MD updated  | About updated | Document References | Code Deleted | Public Archived |" >> $filename
echo "|------------|-------------|--------------------|--------------------|---------------|---------------------|--------------|-----------------|" >> $filename

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

  document_reference_count="${document_count["$repository"]}"
  if [ -z "${document_reference_count}" ]; then
      document_reference_count=0
      zero_document_reference_count=$((zero_document_reference_count + 1))
  else
      document_reference_count="[${document_reference_count}](./document_reference_count.tsv)"
  fi


  status=$(gh repo view googleapis/${repository} --json isArchived -q '.isArchived')
  if [[ $status == "true" ]]; then
      is_public_archive=true
      archived_stat_count=$((archived_stat_count + 1))
  else
      is_public_archive=false
  fi

  if [[ "$open_issues_count" -eq 0 && "$open_pull_requests" -eq 0 && \
        "$is_present_readme" == "true" && "$is_present_about" == "true" && \
        "$code_deleted" == "true" && "$is_public_archive" == "true" ]]; then
     desired_count=$((desired_count + 1))
     repo_status="✅"
  else
     repo_status=""
  fi
  echo "| $repository $repo_status | $open_issues_count | $open_pull_requests | $is_present_readme | $is_present_about | $document_reference_count | $code_deleted | $is_public_archive |" >> $filename

done

temp_file=$(mktemp)
cat << EOL > $temp_file
# $language

Repositories with desirable state:$desired_count/$total_count repos (the higher, the better):

- Zero open issues: $open_issues_stat_count repos
- Zero pull requests: $open_pr_stat_count repos
- README.md updated: $readme_stat_count repos
- About updated: $about_stat_count repos
- Zero document references: $zero_document_reference_count repos
- Code Deleted: $code_deleted_stat_count repos
- Public Archived: $archived_stat_count repos

EOL
cat $filename >> $temp_file
mv $temp_file $filename
echo "Wrote $filename"
