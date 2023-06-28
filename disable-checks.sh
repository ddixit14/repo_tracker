#!/bin/bash

# Given a repositories.txt containing repositories under googleapis org, this script captures 5 things about each repository
# 1. owlbot status (0=inactive, 1=active)
# 2. release-please status (0=inactive, 1=active)
# 3. renovate bot status (0=inactive, 1=active)
# 4. open issues count
# 5. open pull requests count

set +e

repositories="open_prs_repository.txt"

for repository in $(cat $repositories) ; do

  echo $repository
  gh api \
     --method DELETE \
     -H "Accept: application/vnd.github+json" \
     -H "X-GitHub-Api-Version: 2022-11-28" \
     "/repos/googleapis/$repository/branches/main/protection/required_status_checks"


  echo "-------------------------------------------------------------------------------"
  done