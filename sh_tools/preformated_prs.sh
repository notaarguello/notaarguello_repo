#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

BRANCH_NAME=$1

if git branch --list | grep -q "^[\* ]*${BRANCH_NAME}$"; then
  echo "Branch name '$BRANCH_NAME' already exists. Checking out the branch and exiting..."
  git checkout "$BRANCH_NAME"
  exit 1
fi

DATE=$(date +%Y%m%d%H%M)
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
STASH_NAME="${DATE}-${CURRENT_BRANCH}-autostash"

TOOLS_DIR=$(dirname $0)

git stash push -m "$STASH_NAME"


if ! git checkout master; then
  echo "Failed to checkout master. Trying main..."
  # If master fails, attempt to checkout main branch
  if ! git checkout main; then
    echo "Failed to checkout main. Exiting..."
    exit 1
  fi
fi

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

PR_CREATION_OUTPUT=$(gh pr create --title "Merge $BRANCH_NAME into master" --body "$PR_TEMPLATE" --base master --head "$BRANCH_NAME" 2>&1)
echo "$PR_CREATION_OUTPUT"
git pull
git rm "${REPO_ROOT}/dummy.txt"
git commit -m "removed dummy.txt file"
git push

source "${TOOLS_DIR}/obsidian_tools.sh"
NOTE_PATH="PRS/${REPO_NAME}"
postNoteToObsidian "$NOTE_PATH" "$BRANCH_NAME" "$PR_CREATION_OUTPUT"
patchContentToDailyNoteObsidian "Tickets:" "[[${BRANCH_NAME}]]"