#!/bin/bash

# Check if user has Bash on their system
if ! command -v bash &> /dev/null; then
  echo "🚫 Bash is required to run this script. Please install Bash and try again."
  exit
fi

# Check if the required dependencies exist and prompt the user to install any missing dependencies
missing_dependencies=""
if ! command -v jq &> /dev/null; then
  missing_dependencies+="jq "
fi

if [ -n "$missing_dependencies" ]; then
  echo "🔍 The following dependencies are missing: $missing_dependencies"
  echo "💻 Please install them and try again."
  echo "For example, on macOS, you can install them with Homebrew:"
  echo "brew install $missing_dependencies"
  exit
fi

# Check if the GitHub CLI is installed and prompt the user to install it if it's missing
if ! command -v gh &> /dev/null; then
  echo "🔍 The GitHub CLI is not installed on your system."
  echo "💻 Please install it and try again."
  echo "You can download the GitHub CLI from the following link:"
  echo "https://cli.github.com/manual/installation"
  exit
fi

# Define the default repository name and description
if [ $# -eq 1 ]; then
  project_path="$1"
  if [ -f "$project_path/package.json" ]; then
    repo_name=$(jq -r '.name' "$project_path/package.json")
    repo_description=$(jq -r '.description' "$project_path/package.json")
  else
    echo "🤔 There is no package.json file in the provided project path."
    echo "📝 Please enter the repository name and description manually:"
    read -r -p "Repository name: " repo_name
    read -r -p "Repository description (optional): " repo_description
  fi
else
  repo_name=$(jq -r '.name' package.json)
  repo_description=$(jq -r '.description' package.json)
fi

if [ -z "$repo_name" ]; then
  echo "🤔 The package.json file does not contain a valid name property."
  echo "📝 Please enter the repository name manually:"
  read -r -p "Repository name: " repo_name
fi

if [ -z "$repo_description" ]; then
  echo "📝 Please enter the repository description (optional):"
  read -r repo_description
fi

# Initialize a Git repository
if [ -n "$project_path" ]; then
  if [ ! -d "$project_path" ]; then
    echo "🤔 The provided project path does not exist."
    echo "📝 Initializing a Git repository in the current directory instead."
    git init
  else
    cd "$project_path" || exit
    git init
  fi
else
  git init
fi

# Add all files to Git staging area and make the initial commit
git add .
git commit -m "🎉 Initial commit"

# Create the new repository on GitHub using the GitHub CLI
github_username=$(gh config get -h github.com user)
gh repo create "$github_username/$repo_name" --description "$repo_description" --public || { echo "❌ Failed to create repository $repo_name on GitHub."; exit 1; }

# Push the initial commit to the main branch
git remote add origin "https://github.com/$github_username/$repo_name.git"
git push -u origin main

# Output
