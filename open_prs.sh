#!/bin/bash

# Given a repositories.txt containing repositories under googleapis org, this script captures 5 things about each repository
# 1. owlbot status (0=inactive, 1=active)
# 2. release-please status (0=inactive, 1=active)
# 3. renovate bot status (0=inactive, 1=active)
# 4. open issues count
# 5. open pull requests count

set -e

repositories="open_prs_repository.txt"
content_file="release-please-config.txt"

for repository in $(cat $repositories); do

  echo $repository

  if ! (git clone git@github.com:googleapis/${repository}.git)
      then
        echo ${repository}
      else
        # Clone the repository
        cd "$repository"

        # Checkout a new branch
        git checkout -b "dixit14-rpbb"

        file_path=".github/release-please.yml"    # Replace with the desired file path in the repository
        commit_message="chore: Bringing back release-please.yml"  # Replace with the commit message

        # Read the content from the file
        content=$(cat "../$content_file")

        # Create the new file locally
        echo "$content" > "$file_path"

        git add .github/release-please.yml
        # Commit the changes
        git commit -m "chore: Bringing back release-please.yml"

        # Push the changes to the remote repository
        git push --set-upstream origin "dixit14-rpbb"

        # Create a pull request
        PR_OUTPUT=$(gh pr create --title "$commit_message" --body "This PR brings back release-please.yml" --base main --head "dixit14-rpbb")


        echo $PR_OUTPUT>>../prs-raised.txt
      fi
      cd ..
      rm -rf $repository
  done