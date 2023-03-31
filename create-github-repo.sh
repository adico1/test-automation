#!/bin/bash

# Check for required dependencies
if ! command -v gh &> /dev/null; then
    echo "⚠️ The GitHub CLI (gh) is not installed. Please install it before running this script: https://cli.github.com/manual/installation"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️ The jq utility is not installed. Please install it before running this script."
    exit 1
fi

# Check if a project path was provided, otherwise use the current directory
if [ -z "$1" ]; then
    PROJECT_DIR="."
else
    PROJECT_DIR="$1"
fi

# Check if package.json exists in the project directory
if [ ! -f "$PROJECT_DIR/package.json" ]; then
    echo "❌ package.json not found in $PROJECT_DIR. Please provide a repository name and description."
    read -p "Enter repository name: " REPO_NAME
    read -p "Enter repository description: " REPO_DESC
else
    # Extract repository name and description from package.json
    REPO_NAME=$(jq -r '.name' "$PROJECT_DIR/package.json")
    REPO_DESC=$(jq -r '.description' "$PROJECT_DIR/package.json")

    # If package.json does not have a name field, prompt the user for a repository name
    if [ "$REPO_NAME" = "null" ]; then
        echo "❌ package.json in $PROJECT_DIR does not have a name field. Please provide a repository name."
        read -p "Enter repository name: " REPO_NAME
    fi

    # If package.json does not have a description field, prompt the user for a repository description
    if [ "$REPO_DESC" = "null" ]; then
        echo "⚠️ package.json in $PROJECT_DIR does not have a description field. Please provide a repository description."
        read -p "Enter repository description: " REPO_DESC
    fi
fi

# Check if repository name is available on GitHub
if gh repo view "$REPO_NAME" > /dev/null 2>&1; then
    echo "❌ Repository name $REPO_NAME is already taken on GitHub. Please choose a different name."
    exit 1
fi

# Create repository on GitHub
echo "🚀 Creating repository $REPO_NAME on GitHub..."
gh repo create "$REPO_NAME" --public --description "$REPO_DESC" > /dev/null

# Initialize Git repository and make initial commit
echo "🌱 Initializing Git repository and making initial commit..."
cd "$PROJECT_DIR"
git init > /dev/null
git add . > /dev/null
git commit -m "🎉 Initial commit" > /dev/null

# Push to remote repository on GitHub
echo "🚀 Pushing initial commit to remote repository on GitHub..."
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" > /dev/null
git push -u origin main > /dev/null

# Show success message
echo "🎉 Successfully created repository $REPO_NAME on GitHub!"
