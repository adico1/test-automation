#!/usr/bin/env bash

# Define emoji variables
ROCKET="🚀"
TERMINAL="💻"
PACKAGE="📦"
SETUP="🛠️"
STAR="🌟"
TIP="💡"
PROMPT="🤔"
LOG="📝"
ERROR="❌"

# Get package.json file location
if [ -z "$1" ]; then
  PKG_FILE="./package.json"
  echo "${TIP} No project path provided. Using package.json file in current directory."
else
  PKG_FILE="$1/package.json"
  echo "${TIP} Using package.json file in $1 directory."
fi

# Parse repository name and description from package.json file
if [ -f "$PKG_FILE" ]; then
  echo "${ROCKET} Parsing repository name and description from $PKG_FILE"
  REPO_NAME=$(jq -r '.name' $PKG_FILE)
  REPO_DESC=$(jq -r '.description' $PKG_FILE)
else
  echo "${PROMPT} No package.json file found. Please enter the repository name:"
  read REPO_NAME
  echo "${PROMPT} Please enter the repository description (optional):"
  read REPO_DESC
fi

# Check if required dependencies are installed
echo "${ROCKET} Checking dependencies..."
if [ -z "$(which jq)" ]; then
  echo "${ERROR} jq is not installed. Please install jq using your package manager."
  exit 1
fi
if [ -z "$(which git)" ]; then
  echo "${ERROR} git is not installed. Please install git using your package manager."
  exit 1
fi
if [ -z "$(which gh)" ]; then
  echo "${ERROR} gh is not installed. Please install gh from https://github.com/cli/cli/releases/tag/v2.25.1"
  exit 1
else
  GH_VERSION=$(gh --version | awk '{print $3}')
  if [ "$GH_VERSION" != "2.25.1" ]; then
    echo "${ERROR} Incorrect version of gh installed. Please install gh version 2.25.1 from https://github.com/cli/cli/releases/tag/v2.25.1"
    exit 1
  fi
fi

# Set the GITHUB_USER variable
GITHUB_USER=$(gh config get -h github.com user)

# Check if user is logged in to gh CLI
echo "Checking if user is logged in to gh CLI..."
if ! gh auth status; then
  echo "User is not logged in to gh CLI. Please log in using the command: gh auth login"
  exit 1
fi

# Ask the user where to create the repository
echo "Where would you like to create the repository?"
echo "1) Under your personal account"
echo "2) Under an organization"
read -p "#? " REPO_LOCATION

# Create the repository
echo "Creating repository $REPO_NAME..."
if [ "$REPO_LOCATION" = "1" ]; then
  gh repo create "$GITHUB_USER/$REPO_NAME" --public
else
  echo "Please enter the name of the organization:"
  read ORG_NAME
  gh repo create "$ORG_NAME/$REPO_NAME" --public
fi

# Check if project directory is a Git repository
echo "Checking if project directory is a Git repository..."
if [ -d "./.git" ]; then
  echo "This is already a Git repository."
  read -p "Do you want to use the existing repository? (y/n) " USE_EXISTING_REPO
  if [ "$USE_EXISTING_REPO" = "n" ]; then
    exit 0
  fi
  git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
  echo "This is not yet a Git repository."
  read -p "Do you want to use this directory for Git? (y/n) " USE_EXISTING_REPO
  if [ "$USE_EXISTING_REPO" = "n" ]; then
    exit 0
  fi
  git init
fi

# Set up Git
echo "Setting up Git..."
git add .
git commit -m "Initial commit 🎉"
git push -u origin main

# Finish
echo "🎉 Successfully created repository $REPO_NAME on GitHub!"
echo "You can view your new repository here: https://github.com/$GITHUB_USER/$REPO_NAME"

exit 0