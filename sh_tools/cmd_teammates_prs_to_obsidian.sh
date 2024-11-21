#!/bin/bash

set -eE

cmd_path=$(dirname "$(realpath "$0")")

source "${cmd_path}/obsidian_tools.sh"
source "${cmd_path}/git_helpers.sh"

if [ -z "$GITHUB_TEAMMATES" ]; then
    echo "GITHUB_TEAMMATES is empty. Exiting..."
    exit 1
fi

users_prs=""
repo_with_owner=$(get_repo_root)

echo "$GITHUB_TEAMMATES" | tr ' ' '\n' | while IFS= read -r teammate; do
    prs_for_teammate=$(getLastPrsFromUser "$teammate" "$repo_with_owner")
    if [ -n "$(echo "$prs_for_teammate" | xargs)" ]; then
        users_prs+=$'**User:** '"$teammate"$'\n'"$prs_for_teammate"$'\n\n'
    fi
done

if [ ! -z "$users_prs" ]; then
    patchContentToDailyNoteObsidian "Tickets:" "${users_prs}" "end"
fi
