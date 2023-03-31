#!/bin/bash

# Function to print an error message and exit with an error code
function error {
  echo -e "\033[31mERROR: $1\033[0m"
  exit 1
}

# Check if necessary dependencies are installed
command -v jq > /dev/null || error "jq is not installed. Please install it using your package manager."
command -v git > /dev/null || error "git is not installed. Please install it using your package manager."
command -v gh > /dev/null || error "gh is not installed. Please install it from https://github.com/cli/cli/releases/tag/v2.25.1"

# Get the GitHub username
GITHUB_USER=$(gh config get -h github.com user)

# Parse arguments
if [[ -n $1 ]]; then
  if [[ -f "$1/package.json" ]]; then
    REPO_NAME=$(jq -r '.name' "$1/package.json")
    REPO_DESCRIPTION=$(jq -r '.description' "$1/package.json")
  else
    REPO_NAME=$2
    REPO_DESCRIPTION=$3
  fi
else
  if [[ -f "package.json" ]]; then
    REPO_NAME=$(jq -r '.name' package.json)
    REPO_DESCRIPTION=$(jq -r '.description' package.json)
  else
    read -p "Enter repository name: " REPO_NAME
    read -p "Enter repository description (optional): " REPO_DESCRIPTION
  fi
fi

# Ask the user whether to create the repository under their personal account or an organization
echo -e "\nWhere do you want to create the repository?"
select account_type in "Personal" "Organization"; do
  case $account_type in
    "Personal")
      REPO_OWNER=$GITHUB_USER
      break
      ;;
    "Organization")
      read -p "Enter the name of the organization: " REPO_OWNER
      break
      ;;
    *)
      echo "Invalid option. Please select 1 or 2."
      ;;
  esac
done

# Confirm with the user that they want to create the repository
echo -e "\nYou are about to create the following repository:"
echo "Name: $REPO_NAME"
echo "Description: $REPO_DESCRIPTION"
echo "Owner: $REPO_OWNER"
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Create the repository
echo -e "\nCreating repository...\n"
gh repo create "$REPO_OWNER/$REPO_NAME" --public || error "Failed to create repository. Please check that the repository name is valid and that you have permission to create repositories under the specified owner."

# Initialize Git and push changes
if [[ -n $1 ]]; then
  if [[ -d "$1/.git" ]]; then
    cd "$1"
  else
    cd "$(dirname "$1")"
  fi
fi
git init
git add .
git commit -m ":tada: Initial commit"
git remote add origin "https://github.com/$REPO_OWNER/$REPO_NAME.git"
git push -u origin "$(git branch --show-current)"

# Print success message with link to repository
echo -e "\n🎉 Successfully created repository $REPO_NAME on GitHub! You can view your new repository here: https://github.com/$REPO_OWNER/$RE