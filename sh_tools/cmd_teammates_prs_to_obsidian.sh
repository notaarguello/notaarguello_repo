#!/bin/bash

set -eE

source "${ANDY_TOOLS_DIR}/obsidian_tools.sh"
source "${ANDY_TOOLS_DIR}/git_helpers.sh"

if [ -z "$GITHUB_TEAMMATES" ]; then
    echo "GITHUB_TEAMMATES is empty. Exiting..."
    exit 1
fi

local users_prs=""
local repo_with_owner=$(get_repo_root)

echo "$GITHUB_TEAMMATES" | tr ' ' '\n' | while IFS= read -r teammate; do
    local prs_for_teammate=$(getLastPrsFromUser "$teammate" "$repo_with_owner")
    if [ -n "$(echo "$prs_for_teammate" | xargs)" ]; then
        users_prs+=$'**User:** '"$teammate"$'\n'"$prs_for_teammate"$'\n\n'
    fi
done

if [ ! -z "$users_prs" ]; then
    patchContentToDailyNoteObsidian "Tickets:" "${users_prs}" "end"
fi
