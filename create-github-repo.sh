#!/bin/bash

# Check for necessary dependencies
if ! command -v bash >/dev/null || ! command -v jq >/dev/null || ! command -v gh >/dev/null; then
  echo "🚨 Please install missing dependencies: bash, jq, and gh (GitHub CLI)." >&2
  echo "💻 For example, run 'brew install bash jq gh'." >&2
  exit 1
fi

# Check for gh version 2.25.1
GH_VERSION=$(gh --version | awk '{print $3}')
if [[ $GH_VERSION != "2.25.1" ]]; then
  echo "🚨 Please install gh version 2.25.1 from https://github.com/cli/cli/releases/tag/v2.25.1." >&2
  exit 1
fi

# Get GitHub username from gh config
GITHUB_USER=$(gh config get -h github.com user)

# Get repository name and description from package.json (if present) or prompt user for input
if [[ -n $1 ]]; then
  if [[ -f "$1/package.json" ]]; then
    REPO_NAME=$(jq -r '.name' "$1/package.json")
    REPO_DESC=$(jq -r '.description' "$1/package.json")
  else
    REPO_NAME="$1"
    read -p "Enter repository description (leave blank for none): " REPO_DESC
  fi
else
  if [[ -f "package.json" ]]; then
    REPO_NAME=$(jq -r '.name' package.json)
    REPO_DESC=$(jq -r '.description' package.json)
  else
    read -p "Enter repository name: " REPO_NAME
    read -p "Enter repository description (leave blank for none): " REPO_DESC
  fi
fi

# Prompt user to confirm repository creation
read -p "Create new repository '$GITHUB_USER/$REPO_NAME' with description '$REPO_DESC'? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Create repository with gh CLI
  gh repo create "$GITHUB_USER/$REPO_NAME" --description "$REPO_DESC" --public || exit 1

  # Initialize Git repository in project path (if present) or current directory
  if [[ -n $1 ]]; then
    cd "$1" || exit 1
  fi
  git init || exit 1

  # Add all files to Git and make initial commit
  git add .
  git commit -m "🎉 Initial commit"
  git branch -M main || exit 1

  # Push to remote repository
  git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" || exit 1
  git push -u origin main || exit 1

  # Display success message
  echo "🎉 Successfully created repository $GITHUB_USER/$REPO_NAME on GitHub!"
else
  echo "👋 No repository created."
fi
