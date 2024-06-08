#!/bin/bash

-eE

cmd_path=$(dirname "$(realpath "$0")")
. "${cmd_path}/git_helpers.sh"

pr_number=$(echo $1 | xargs)
new_branch_sufix=$(echo $2 | xargs)


if [ -z "$pr_number" ] || [ -z "$new_branch_sufix"]; then
    echo "Usage: watch_pr_merged_and_open_pr <PR_NUMBER> <NEW_BRANCH_SUFIX>"
    return 1
fi

watch_pr_merged_and_notify "$pr_number" 

new_branch_name="$(gh pr view "$pr_number" --json headRefName --jq '.headRefName')-${new_branch_sufix}"

"${cmd_path}/cmd_preformated_prs.sh" "$new_branch_name"

prev_pr_commit=$(get_pr_commit_sha "$pr_number")
prev_pr_url=$(get_pr_url "$pr_number")
new_pr_number=$(get_pr_number_for_branch "$new_branch_name")
new_pr_url=$(get_pr_url "$new_pr_number")

cat << EOF
New branch `$new_branch_name` created
  - New PR number: $new_pr_number
  - New PR url: $new_pr_url
  - Prev PR commit: $prev_pr_commit
  - Prev PR url: $prev_pr_url
EOF


