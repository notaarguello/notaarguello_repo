#!/bin/bash


echo $ANDY_TOOLS_DIR
source "${ANDY_TOOLS_DIR}/.env"

alias andy-pf-pr=". ${ANDY_TOOLS_DIR}/cmd_preformated_prs.sh"
alias andy-tm-prs-to-obs=". ${ANDY_TOOLS_DIR}/cmd_teammates_prs_to_obsidian.sh"