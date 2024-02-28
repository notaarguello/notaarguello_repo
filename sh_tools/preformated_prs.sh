#!/bin/bash

# Check if a string was provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

BRANCH_NAME=$1
DATE=$(date +%Y%m%d)
REPO_ROOT=$(git rev-parse --show-toplevel)

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
STASH_NAME="${DATE}-${CURRENT_BRANCH}-autostash"
git stash push -m "$STASH_NAME"


git checkout master
git pull
git checkout -b "$BRANCH_NAME"


touch "${REPO_ROOT}/dummy.txt"
git add "${REPO_ROOT}/dummy.txt"
git commit -m "Added dummy.txt file"


git push --set-upstream origin "$BRANCH_NAME"

if ! gh auth status >/dev/null 2>&1; then
    echo "You need to login: gh auth login"
    exit 1
fi

# Check if .github/pull_request_template.md exists
if [ -f ".github/pull_request_template.md" ]; then
    PR_TEMPLATE=$(cat "${REPO_ROOT}/.github/pull_request_template.md")
else
    PR_TEMPLATE="This PR introduces changes from $BRANCH_NAME into the master branch."
fi

gh pr create --title "Merge $BRANCH_NAME into master" --body "$PR_TEMPLATE" --base master --head "$BRANCH_NAME"
git pull
git rm "${REPO_ROOT}/dummy.txt"
git commit -m "removed dummy.txt file"
git push
