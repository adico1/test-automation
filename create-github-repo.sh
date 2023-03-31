#!/usr/bin/env bash

set -e

# Check if Bash is installed
if [ -z "$(command -v bash)" ]; then
  echo "❌ Bash is not installed. Please install Bash and try again."
  exit 1
fi

# Check if jq is installed
if [ -z "$(command -v jq)" ]; then
  echo "❌ jq is not installed. Please install jq using your package manager or from https://stedolan.github.io/jq/."
  exit 1
fi

# Check if the gh CLI is installed
if [ -z "$(command -v gh)" ]; then
  echo "❌ The gh CLI is not installed. Please install the gh CLI from https://cli.github.com/manual/installation."
  exit 1
fi

# Prompt the user for the project path
if [ -n "$1" ]; then
  project_path="$1"
  package_json="$project_path/package.json"
else
  project_path="."
  package_json="package.json"
fi

# Check if the package.json file exists
if [ ! -f "$package_json" ]; then
  # Prompt the user for the repository name and description
  read -p "Enter the repository name: " repo_name
  read -p "Enter the repository description: " repo_description
else
  # Get the repository name and description from the package.json file
  repo_name=$(jq -r '.name' "$package_json")
  repo_description=$(jq -r '.description' "$package_json")

  # Prompt the user to confirm or change the repository name and description
  read -p "Enter the repository name ($repo_name): " input_repo_name
  if [ -n "$input_repo_name" ]; then
    repo_name="$input_repo_name"
  fi
  read -p "Enter the repository description ($repo_description): " input_repo_description
  if [ -n "$input_repo_description" ]; then
    repo_description="$input_repo_description"
  fi
fi

# Add GitHub username as prefix to the repository name
github_username=$(gh config get -h github.com user)
repo_name="$github_username/$repo_name"

# Create the GitHub repository
echo "🚀 Creating repository $repo_name on GitHub..."
if gh repo create "$repo_name" --description "$repo_description" --public --confirm; then
  echo "🎉 Successfully created repository $repo_name on GitHub!"
else
  echo "❌ Failed to create repository $repo_name on GitHub. Please check your input and try again."
  exit 1
fi

# Initialize Git repository
cd "$project_path"
git init

# Add files to Git staging area
git add .

# Commit changes
git commit -m "🎉 Initial commit"

# Push to main branch
git push -u origin main

echo "🎉 Successfully pushed to branch main in $repo_name on GitHub!"