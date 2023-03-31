#!/bin/bash

# Define some emojis
SUCCESS_EMOJI="🎉"
ERROR_EMOJI="❌"

# Define the minimum required version of the GitHub CLI
MIN_GH_CLI_VERSION="2.25.1"

# Check that the required dependencies are installed
command -v jq >/dev/null 2>&1 || { echo "${ERROR_EMOJI} jq is required but not installed. Please install it before running this script." >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "${ERROR_EMOJI} The GitHub CLI is required but not installed. Please install it before running this script: https://cli.github.com" >&2; exit 1; }

# Check that the user is logged in to GitHub
if ! gh auth status >/dev/null 2>&1; then
  echo "${ERROR_EMOJI} You are not logged in to GitHub. Please log in using 'gh auth login'." >&2
  exit 1
fi

# Get the GitHub username from the system
GITHUB_USERNAME="$(gh config get -h github.com user)"
if [ -z "$GITHUB_USERNAME" ]; then
  read -p "Please enter your GitHub username: " GITHUB_USERNAME
fi

# Check the version of the GitHub CLI
GH_CLI_VERSION="$(gh --version | head -1 | cut -d ' ' -f 3)"
if [ "$GH_CLI_VERSION" != "$MIN_GH_CLI_VERSION" ]; then
  echo "${ERROR_EMOJI} The minimum required version of the GitHub CLI is $MIN_GH_CLI_VERSION, but you are running version $GH_CLI_VERSION. Please upgrade before running this script: https://cli.github.com" >&2
  exit 1
fi

# Prompt the user for the repository name and description
if [ $# -eq 1 ]; then
  REPO_DIR="$1"
  REPO_NAME="$(basename "$REPO_DIR")"
  cd "$REPO_DIR"
else
  read -p "Please enter the name of the new repository: " REPO_NAME
  read -p "Please enter a description for the new repository (leave blank for no description): " REPO_DESCRIPTION
  REPO_DIR="."
fi

# Check if the repository name is available
if gh repo view "$GITHUB_USERNAME/$REPO_NAME" >/dev/null 2>&1; then
  echo "${ERROR_EMOJI} The repository name $REPO_NAME is not available on GitHub. Please choose a different name." >&2
  exit 1
fi

# Initialize the Git repository
git init "$REPO_DIR"
git add .
git commit -m "${SUCCESS_EMOJI} Initial commit"

# Create the new repository on GitHub
gh repo create "$GITHUB_USERNAME/$REPO_NAME" --description="$REPO_DESCRIPTION" --public --enable-wiki --confirm

# Add the GitHub repository as a remote and push the local Git repository to the remote
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
git push -u origin master

echo "${SUCCESS_EMOJI} Successfully created repository $REPO_NAME on GitHub!"
