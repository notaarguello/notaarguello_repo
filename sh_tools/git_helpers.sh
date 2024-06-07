#!bin/bash


# Function to get the last PR for a user
getLastPrsFromUser() {

    local username=$1
    local repo_with_owner=$2

    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    # Specify the GitHub username for which you want to list open pull requests

    # List open pull requests for the specified user in the current repository
    gh_output=$(gh pr list --author "${username}" --repo "${repo_with_owner}" --state "open")
    echo "$gh_output"
}

# Function to get the commit SHA of a PR
get_pr_commit_sha() {
  local pr_number=$1
  local repo_with_owner=$2

  gh_output=$(gh pr view $pr_number --repo $repo_with_owner --json commits --jq '.commits[-1].oid')
  echo "$gh_output"
}

# Function to list names of completed workflow runs for a commit SHA
list_completed_workflow_names_for_commit() {
  local commit_sha=$1
  local repo_with_owner=$2

  gh_output=$(gh run list --repo $repo_with_owner --commit $commit_sha --json name,conclusion,status --jq '.[] | select(.status == "completed") | .name')
  echo "$gh_output"
}

# Function to get the repository name from the current directory
get_repo_from_dir() {
  gh_output=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
  echo "$gh_output"
}

# Function to get the repository name only
get_repo_name() {
  gh_output=$(gh repo view --json name --jq '.name')
  echo "$gh_output"
}

# Function to get the current branch name
get_current_branch() {
  gh_output=$(git rev-parse --abbrev-ref HEAD)
  echo "$gh_output"
}

# Function to get the PR number for the current branch
get_pr_number_for_branch() {
  local branch_name=$1
  local repo_with_owner=$2
  gh_output=$(gh pr list --repo $repo_with_owner --head $branch_name --json number --jq '.[0].number')
  echo "$gh_output"
}

# Function to get the root directory of the Git repository
get_repo_root() {
  gh_output=$(git rev-parse --show-toplevel)
  echo "$gh_output"
}

set_gh_aux_env_vars() {

    local repo_with_owner=$(get_repo_from_dir)
    local repo_name=$(get_repo_name)
    local current_branch=$(get_current_branch)
    local pr_number=$(get_pr_number_for_branch $current_branch $repo_with_owner)
    local commit_sha=$(get_pr_commit_sha $pr_number $repo_with_owner)
    local repo_root=$(get_repo_root)

    export GH_REPO_WITH_OWNER=$repo_with_owner
    export GH_REPO_NAME=$repo_name
    export GH_CURR_BRANCH_PR_NUMBER=$pr_number
    export GH_CURR_BRANCH_SHA=$commit_sha
    export GH_REPO_ROOT=$repo_root

    echo "GH_REPO_WITH_OWNER=$GH_REPO_WITH_OWNER"
    echo "GH_REPO_NAME=$GH_REPO_NAME"
    echo "GH_CURR_BRANCH_PR_NUMBER=$GH_CURR_BRANCH_PR_NUMBER"
    echo "GH_CURR_BRANCH_SHA=$GH_CURR_BRANCH_SHA"
    echo "GH_REPO_ROOT=$GH_REPO_ROOT"
}

# Function to check if PR is merged
check_pr_merged() {
  local pr_number=$1
  local repo_with_owner=$2

  gh_output=$(gh pr view $pr_number --repo $repo_with_owner --json merged --jq '.merged')
  echo "$gh_output"
}

# Function to check if PR is merged every 2 mins and emit a notification when done
watch_pr_merged_and_notify() {
    local pr_number=$1
    local repo_with_owner=$2

    local max_time=$((40 * 60))
    local interval=120
    local elapsed_time=0

    while [ $elapsed_time -lt $max_time ]; do
        local merged_status=$(check_pr_merged $pr_number $repo_with_owner)
        if [ "$merged_status" == "true" ]; then
            # Emit a sound alert
            afplay /System/Library/Sounds/Glass.aiff
            say "The pull request ${pr_number} has been merged."
            return 0
        else
            echo "The pull request #$pr_number has not been merged. Checking again in 2 minutes..."
            sleep $interval
            elapsed_time=$((elapsed_time + interval))
        fi
    done

    say "The pull request #$pr_number has not been merged after 40 minutes."
    return 1
}

# Function to check if a specific workflow run is completed
check_workflow_completed() {
    local workflow_name=$1
    local commit_sha=$2
    local repo_with_owner=$3

    gh_output=$(gh run list --repo $repo_with_owner --commit $commit_sha --json name,status --jq ".[] | select(.name == \"$workflow_name\") | .status")
    echo "$gh_output"
}

# Function to check if a specific workflow run is completed every 2 mins and emit a notification when done
watch_workflow_and_notify() {
    local workflow_name=$1
    local commit_sha=$2
    local repo_with_owner=$3

    local max_time=$((40 * 60))
    local interval=120
    local elapsed_time=0

    while [ $elapsed_time -lt $max_time ]; do
        local workflow_status=$(check_workflow_completed $workflow_name $commit_sha $repo_with_owner)
        if [ "$workflow_status" == "completed" ]; then
            # Emit a sound alert
            afplay /System/Library/Sounds/Glass.aiff
            say "The workflow ${workflow_name} has completed."
            return 0
        else
            echo "The workflow ${workflow_name} is not completed. Checking again in 2 minutes..."
            sleep $interval
            elapsed_time=$((elapsed_time + interval))
        fi
    done

    say "The workflow ${workflow_name} has not completed after 40 minutes."
    return 1
}