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
echo "| Repository | Open Issues | Open Pull Requests |" >> $language-results.md
echo "|------------|-------------|--------------------|" >> $language-results.md

for repository in $(cat $repositories); do

  open_issues_count=$(gh issue list -R googleapis/${repository} -L 100 -s open | wc -l)
  open_pull_requests=$(gh pr list -R googleapis/${repository} -L 100 -s open | wc -l)

  echo "| $repository | $open_issues_count | $open_pull_requests |" >> $language-results.md

done


