#!/bin/bash

# Define emojis
ROCKET="🚀"
SMILEY="😄"
THUMBS_UP="👍"

# Check if user is authenticated with GitHub
if ! gh auth status > /dev/null; then
  echo "${ROCKET} You need to log in to your GitHub account."
  gh auth login
fi

# Check if necessary dependencies are installed
if ! command -v jq > /dev/null; then
  echo "${ROCKET} jq is required. Please install it and run this script again."
  echo "You can install jq with Homebrew: 'brew install jq'"
  exit 1
fi

# Get project path (if provided)
if [ -z "$1" ]; then
  PROJECT_PATH="."
else
  PROJECT_PATH="$1"
fi

# Initialize Git repository (if necessary)
if [ ! -d "$PROJECT_PATH/.git" ]; then
  git init "$PROJECT_PATH"
  echo "${SMILEY} Initialized Git repository in $PROJECT_PATH"
fi

# Read repository name and description from package.json (if available)
if [ -f "$PROJECT_PATH/package.json" ]; then
  REPO_NAME=$(jq -r '.name' "$PROJECT_PATH/package.json")
  REPO_DESC=$(jq -r '.description' "$PROJECT_PATH/package.json")
else
  # Prompt user for repository name and description
  echo "${ROCKET} Repository name and description not found in package.json"
  read -p "Enter repository name: " REPO_NAME
  read -p "Enter repository description (optional): " REPO_DESC
fi

# Check if repository name is available on GitHub
USERNAME=$(gh config get -h github.com user)
REPO_EXISTS=$(gh api --silent --paginate "/users/$USERNAME/repos" | jq -r ".[].name" | grep -cx "$REPO_NAME")
if [ "$REPO_EXISTS" -ne 0 ]; then
  echo "${ROCKET} The repository name '$REPO_NAME' already exists for user '$USERNAME'. Please choose a different name."
  exit 1
fi

# Create repository on GitHub
gh repo create "$REPO_NAME" --public --description "$REPO_DESC" --yes

# Add remote repository and push changes
REMOTE_URL=$(gh repo view "$REPO_NAME" --json clone_url | jq -r ".clone_url")
git remote add origin "$REMOTE_URL"
git add .
git commit -m "${ROCKET} Initial commit"
git push -u origin main

# Display success message
echo "${THUMBS_UP} Repository created successfully at $REMOTE_URL"