#!/bin/bash


source "${ANDY_TOOLS_DIR}/obsidian_tools.sh"
source "${ANDY_TOOLS_DIR}/git_helpers.sh"

local teammates="$GITHUB_TEAMMATES"
local IFS=' ' read -r -a teammates_array <<< "$teammates"

# Iterate over each teammate and list open pull requests for them
local users_prs=""
for teammate in "${teammates_array[@]}"; do
    local prs_for_teammate=$(list_open_prs_for_user "$teammate")
    users_prs+="#### User: $teammate\n$prs_for_teammate\n\n"
    patchContentToDailyNoteObsidian patchContentToDailyNoteObsidian "Tickets:" "${users_prs}" "end"
done