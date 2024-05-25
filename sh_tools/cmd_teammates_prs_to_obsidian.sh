#!/bin/bash

set -eEx

source "${ANDY_TOOLS_DIR}/obsidian_tools.sh"
source "${ANDY_TOOLS_DIR}/git_helpers.sh"

if [ -z "$GITHUB_TEAMMATES" ]; then
    echo "GITHUB_TEAMMATES is empty. Exiting..."
    exit 1
fi

users_prs=""
echo "$GITHUB_TEAMMATES" | tr ' ' '\n' | while IFS= read -r teammate; do
    prs_for_teammate=$(getLastPrsFromUser "$teammate")
    if [ -n "$(echo "$prs_for_teammate" | xargs)" ]; then
        users_prs+=$'**User:** '"$teammate"$'\n'"$prs_for_teammate"$'\n\n'
    fi
done

if [ ! -z "$users_prs" ]; then
    patchContentToDailyNoteObsidian "Tickets:" "${users_prs}" "end"
fi
