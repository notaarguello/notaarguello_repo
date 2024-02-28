#!bin/bash


getLastPrsFromUser() {

    local username=$1
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    local repo=$(git remote get-url origin | sed -n 's#.*/\([^/]*\)/\([^/]*\)\.git#\1/\2#p')

    # Specify the GitHub username for which you want to list open pull requests

    # List open pull requests for the specified user in the current repository
    local gh_output=$(gh pr list --author $username --repo $repo --state open)
    echo "$gh_output"
}