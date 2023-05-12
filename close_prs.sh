#!/bin/bash

# this script closes all open pr's in a repo by a particular user, renovate-bot here.

set +e

for repository in $(cat repositories.txt); do

  if ! (git clone git@github.com:googleapis/${repository}.git)
      then
        echo ${repository}
      else
        # Clone the repository
        cd "$repository"

        PR_LIST=$(gh pr list --repo https://github.com/googleapis/${repository} -A renovate-bot --state open | awk '{print $1}')

        # Iterate through the list of pull requests and close them
        for PR_NUMBER in $PR_LIST; do
            echo "Closing PR in ${repository} - #$PR_NUMBER">>pr_closed.txt
            gh pr close $PR_NUMBER
        done

      fi
      cd ..
      rm -rf ${repository}
  done
