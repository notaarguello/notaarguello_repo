#!/bin/bash

-eE

cmd_path=$(dirname "$(realpath "$0")")
. "${cmd_path}/git_helpers.sh"

pr_number=$(echo $1 | xargs)
repo_with_owner=$(echo $2 | xargs)
new_branch_sufix=$(echo $3 | xargs)


if [ -z "$pr_number" ] || [ -z "$repo_with_owner" ] || [ -z "$new_branch_sufix"]; then
    echo "Usage: watch_pr_merged_and_open_pr <PR_NUMBER> <REPO_WITH_OWNER> <NEW_BRANCH_SUFIX>"
    return 1
fi

watch_pr_merged_and_notify "$pr_number" "$repo_with_owner"

new_branch_name="$(gh pr view "$pr_number" --json headRefName --jq '.headRefName')-"

"${cmd_path}/cmd_preformated_prs.sh" "$new_branch_name"


