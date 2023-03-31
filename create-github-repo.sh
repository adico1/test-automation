#!/bin/bash

# Check if Bash is installed
if ! command -v bash &> /dev/null; then
    echo "😕 Bash is not installed on this system. Please install Bash and try again."
    exit 1
fi

# Check for dependencies
if ! command -v gh &> /dev/null; then
    echo "😕 The GitHub CLI (gh) is not installed on this system. Please install it and try again."
    echo "   See https://cli.github.com/manual/installation for instructions."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "😕 The jq command is not installed on this system. Please install it and try again."
    echo "   For example, on macOS, you can install jq with Homebrew: brew install jq"
    exit 1
fi

# Get the GitHub username
GITHUB_USERNAME=$(gh config get -h github.com user)

# Determine the project directory and package information
if [ -z "$1" ]; then
    PROJECT_DIR="."
else
    PROJECT_DIR="$1"
fi

if [ -f "$PROJECT_DIR/package.json" ]; then
    REPO_NAME=$(jq -r '.name' "$PROJECT_DIR/package.json")
    REPO_DESCRIPTION=$(jq -r '.description' "$PROJECT_DIR/package.json")
else
    echo "🤔 No package.json file was found in the project directory. Please provide a name and description for the repository."
    read -p "Repository name (including the $GITHUB_USERNAME prefix, e.g. $GITHUB_USERNAME/my-repo): " REPO_NAME
    read -p "Repository description: " REPO_DESCRIPTION
fi

# Create the repository
echo "🚀 Creating repository $REPO_NAME on GitHub..."
gh repo create "$REPO_NAME" --public --description "$REPO_DESCRIPTION"

if [ $? -ne 0 ]; then
    echo "❌ An error occurred while creating the repository. Please try again."
    exit 1
fi

# Initialize a Git repository
cd "$PROJECT_DIR" || exit 1
git init

# Add all files to the Git staging area
git add .

# Commit the changes with an emoji
git commit -m "🎉 Initial commit" --no-verify

# Push to the remote repository
git remote add origin "https://github.com/$REPO_NAME.git"
git push -u origin main

echo "🎉 Successfully created repository $REPO_NAME on GitHub!"
