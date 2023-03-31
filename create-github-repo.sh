#!/bin/bash

# Check for dependencies
if ! command -v gh &> /dev/null; then
    echo "❌ Please install the GitHub CLI: https://cli.github.com/manual/installation"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ Please install jq: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Set variables
REPO_NAME=""
DESCRIPTION=""
USERNAME=$(gh auth status | jq -r '.user.login')
TOKEN=$(gh auth status | jq -r '.token')
PROJECT_PATH=$1
PACKAGE_JSON="$PROJECT_PATH/package.json"
DEFAULT_BRANCH="main"

# Function to get user input
get_input() {
    read -p "$1: " VAR
    while [ -z "$VAR" ]
    do
        read -p "$1: " VAR
    done
    echo "$VAR"
}

# Function to check if repository name is available on GitHub
check_repo_name() {
    if gh repo view "$REPO_NAME" > /dev/null 2>&1; then
        echo "❌ Repository name '$REPO_NAME' already exists on GitHub. Please choose a different name."
        exit 1
    fi
}

# Check if package.json exists and extract repository name and description
if [ -f "$PACKAGE_JSON" ]; then
    REPO_NAME=$(jq -r '.name' "$PACKAGE_JSON")
    DESCRIPTION=$(jq -r '.description' "$PACKAGE_JSON")
fi

# Get user input for repository name and description if they are not set from package.json
if [ -z "$REPO_NAME" ]; then
    REPO_NAME=$(get_input "Enter repository name")
    check_repo_name
fi

if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION=$(get_input "Enter repository description (optional)")
fi

# Create repository
gh repo create "$USERNAME/$REPO_NAME" --description="$DESCRIPTION" --public --confirm

# Initialize Git repository, commit changes, and push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin "https://github.com/$USERNAME/$REPO_NAME.git"
git push -u origin "$DEFAULT_BRANCH"

# Output success message
echo "✅ Repository created: https://github.com/$USERNAME/$REPO_NAME"