#!/bin/bash

set -eE

if [ $# -ne 1 ]; then
  echo "Usage: $0 <wf-to-watch>"
  exit 1
fi

wf_to_watch=$(echo $1 | xargs)

cmd_path=$(dirname "$(realpath "$0")")
. "${cmd_path}/git_helpers.sh"

validate_workflow_exists() {
    local workflow_name=$1
    local repo_with_owner=$(get_repo_with_owner)

    if ! gh workflow list --repo "$repo_with_owner" --json name --jq '.[] | select(.name == "'"$workflow_name"'") | .name' >/dev/null; then
        echo "Error: Workflow '$workflow_name' does not exist in the repository '$repo_with_owner'."
        exit 1
    fi
}

validate_workflow_exists "$wf_to_watch"

git push
branch_name=$(get_current_branch)
pr_number=$(get_pr_number_for_branch "$branch_name")

watch_workflow_and_notify "$pr_number" "$wf_to_watch"
