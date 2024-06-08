#!/bin/bash

cmd_path=$(dirname "$(realpath "$0")")

. "${cmd_path}/git_helpers.sh"

set_gh_aux_env_vars

help() {
    echo 'Available commands:'
    echo '  - agh_get_last_prs'
    echo '  - agh_get_last_prs_closed'
    echo '  - agh_get_pr_commit'
    echo '  - agh_list_completed_wf_for_commit'
    echo '  - agh_get_repo_with_owner'
    echo '  - agh_get_repo_name'
    echo '  - agh_get_pr_for_branch'
    echo '  - agh_get_repo_root'
    echo '  - agh_set_gh_env'
    echo '  - agh_is_pr_merged'
    echo '  - agh_watch_pr_and_notify'
    echo '  - agh_is_wf_completed'
    echo '  - agh_watch_wf_and_notify'
    echo '  - agh_help'
    #echo '\n'
    echo 'Available vars:'
    printenv | grep '^GH_'
}

# Create aliases for the functions
alias agh_get_last_prs='get_last_prs_from_user'
alias agh_get_last_prs_closed='get_last_closed_prs_from_user'
alias agh_get_pr_commit='get_pr_commit_sha'
alias agh_list_completed_wf_for_commit='list_completed_workflow_names_for_commit'
alias agh_get_repo_with_owner='get_repo_with_owner'
alias agh_get_repo_name='get_repo_name'
alias agh_get_pr_for_branch='get_pr_number_for_branch'
alias agh_get_repo_root='get_repo_root'
alias agh_set_gh_env='set_gh_aux_env_vars'
alias agh_is_pr_merged='check_pr_merged'
alias agh_watch_pr_and_notify='watch_pr_merged_and_notify'
alias agh_is_wf_completed='check_workflow_completed'
alias agh_watch_wf_and_notify='watch_workflow_and_notify'
alias agh_help='help'

help