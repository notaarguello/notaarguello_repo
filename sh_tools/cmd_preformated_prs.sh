#!/bin/bash

set -eE

if [ $# -ne 1 ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

branch_name=$(echo $1 | xargs)

if git branch --list | grep -q "^[\* ]*${branch_name}$"; then
  echo "Branch name '$branch_name' already exists. Checking out the branch and exiting..."
  git checkout "$branch_name"
  exit 1
fi

date=$(date +%Y%m%d%H%M)
repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")

current_branch=$(git rev-parse --abbrev-ref HEAD)
stash_name="${date}-${current_branch}-autostash"


git stash push -m "$stash_name"


if ! git checkout master; then
  echo "Failed to checkout master. Trying main..."
  # If master fails, attempt to checkout main branch
  if ! git checkout main; then
    echo "Failed to checkout main. Exiting..."
    exit 1
  fi
fi

git pull
git checkout -b "$branch_name"


touch "${repo_root}/dummy.txt"
git add "${repo_root}/dummy.txt"
git commit -m "Added dummy.txt file"


git push --set-upstream origin "$branch_name"

if ! gh auth status >/dev/null 2>&1; then
    echo "You need to login: gh auth login"
    exit 1
fi

# Check if .github/pull_request_template.md exists
if [ -f ".github/pull_request_template.md" ]; then
    pr_template=$(cat "${repo_root}/.github/pull_request_template.md")
else
    pr_template="This PR introduces changes from $branch_name into the master branch."
fi

pr_creation_output=$(gh pr create --title "Merge $branch_name into master" --body "$pr_template" --base master --head "$branch_name" 2>&1)
echo "$pr_creation_output"
git pull
git rm "${repo_root}/dummy.txt"
git commit -m "removed dummy.txt file"
git push

source "${ANDY_TOOLS_DIR}/obsidian_tools.sh"
note_path="PRS/${repo_name}"
postNoteToObsidian "$note_path" "$branch_name" "$pr_creation_output"
patchContentToDailyNoteObsidian "Tickets:" "[[${branch_name}]]" "beginning"