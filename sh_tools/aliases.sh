#!/bin/bash


cmd_path=$(dirname "$(realpath "$0")")
source "${cmd_path}/.env"

alias andy-pf-pr=". ${cmd_path}/cmd_preformated_prs.sh"
alias andy-tm-prs-to-obs=". ${cmd_path}/cmd_teammates_prs_to_obsidian.sh"
alias andy-load-git-helpers=". ${cmd_path}/cmd_load_git_helpers.sh"
alias andy-watch-pr-and-open=". ${cmd_path}/cmd_watch_pr_and_open.sh"