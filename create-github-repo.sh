#!/usr/bin/env bash

set -e

# Define variables
PACKAGE_JSON="package.json"
PROJECT_PATH=""
REPO_NAME=""
REPO_DESC=""
GITHUB_USER=""
GH_VERSION="2.25.1"
GH_COMMAND=""
ORG_NAME=""
CREATE_ORG=""
CREATE_PERSONAL=""
GIT_COMMAND=""
INITIALIZED_GIT=""
INITIALIZED_REPO=""
BRANCH_NAME="$(git symbolic-ref --short HEAD)"

# Define functions

function check_dependency {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ $1 is not installed."
    echo "Please install $1 to proceed."
    echo "For example, you can install $1 using the following command:"
    echo "  $2"
    read -rp "Do you want to install $1 now? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      eval "$2"
      if ! command -v "$1" >/dev/null 2>&1; then
        echo "❌ $1 is not installed. Aborting."
        exit 1
      else
        echo "✅ $1 is installed."
      fi
    else
      echo "❌ $1 is required to proceed. Aborting."
      exit 1
    fi
  else
    echo "✅ $1 is installed."
  fi
}

function check_gh_cli {
  if ! command -v "gh" >/dev/null 2>&1; then
    echo "❌ gh CLI is not installed."
    echo "Please install gh CLI to proceed."
    echo "You can download gh CLI v$GH_VERSION from https://github.com/cli/cli/releases/tag/v$GH_VERSION"
    echo "After downloading, you can add it to your PATH by running the following command:"
    echo "  export PATH=\$PATH:/path/to/gh/cli"
    echo "Note: Make sure to replace /path/to/gh/cli with the actual path where you downloaded the gh CLI."
    read -rp "Do you want to continue without gh CLI? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Continuing without gh CLI."
      GH_COMMAND="echo"
    else
      echo "❌ gh CLI is required to proceed. Aborting."
      exit 1
    fi
  else
    GH_COMMAND="gh"
    echo "✅ gh CLI is installed."
  fi
}

function check_logged_in {
  if ! $GH_COMMAND auth status >/dev/null 2>&1; then
    echo "❌ You are not logged in to the gh CLI."
    echo "Please log in using the following command:"
    echo "  $GH_COMMAND auth login"
    exit 1
  else
    echo "✅ You are logged in to the gh CLI."
  fi
}

function check_initialized_git {
  if [[ $INITIALIZED_GIT == "" ]]; then
    if [[ -d "$PROJECT_PATH" ]]; then
      GIT_COMMAND="cd $PROJECT_PATH && git"
      echo "✅ Initialized git in $PROJECT_PATH"
    else
      GIT_COMMAND="git"
      echo "✅ Initialized git in current directory"
    fi
    INITIALIZED_GIT=true
  fi
}

function create_repository {
  if [[ $CREATE_ORG != "" ]]; then
    echo "Creating repository under the $CREATE_ORG organization."
    if ! $GH_COMMAND repo create "$CREATE_ORG/$REPO_NAME"
      --public --description "$REPO_DESC" >/dev/null 2>&1; then
      echo "❌ Error creating repository under the $CREATE_ORG organization."
      exit 1
    else
      echo "✅ Successfully created repository $REPO_NAME under the $CREATE_ORG organization!"
      echo "🎉 You can view your new repository here: https://github.com/$CREATE_ORG/$REPO_NAME"
    fi
  elif [[ $CREATE_PERSONAL != "" ]]; then
    echo "Creating repository under your personal account."
    if ! $GH_COMMAND repo create "$GITHUB_USER/$REPO_NAME" --public --description "$REPO_DESC" >/dev/null 2>&1; then
      echo "❌ Error creating repository under your personal account."
      exit 1
    else
      echo "✅ Successfully created repository $REPO_NAME under your personal account!"
      echo "🎉 You can view your new repository here: https://github.com/$GITHUB_USER/$REPO_NAME"
    fi
  fi
}

# Check dependencies
check_dependency "jq" "sudo apt-get install jq" # Replace with the appropriate command for your package manager
check_dependency "git" "sudo apt-get install git" # Replace with the appropriate command for your package manager
check_gh_cli

# Check gh CLI version
if ! $GH_COMMAND version | grep -q "gh version $GH_VERSION"; then
  echo "❌ Unsupported gh CLI version. Please download gh CLI v$GH_VERSION from https://github.com/cli/cli/releases/tag/v$GH_VERSION"
  exit 1
fi

# Check if user is logged in to the gh CLI
check_logged_in

# Get GitHub username
GITHUB_USER=$($GH_COMMAND config get -h github.com user)
echo "✅ Got GitHub username: $GITHUB_USER"

# Check if project path is provided
if [[ $# -eq 1 ]]; then
  PROJECT_PATH=$1
  if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "❌ Invalid project path: $PROJECT_PATH"
    exit 1
  fi
  echo "✅ Using project path: $PROJECT_PATH"
fi

# Check if package.json exists
if [[ -f "$PROJECT_PATH/$PACKAGE_JSON" ]]; then
  REPO_NAME=$(jq -r '.name' "$PROJECT_PATH/$PACKAGE_JSON")
  REPO_DESC=$(jq -r '.description' "$PROJECT_PATH/$PACKAGE_JSON")
  echo "✅ Got repository name and description from $PROJECT_PATH/$PACKAGE_JSON"
else
  # Get repository name
  if [[ $# -ge 1 ]]; then
    REPO_NAME=$1
  else
    read -rp "Enter repository name: " REPO_NAME
  fi

  # Get repository description
  if [[ $# -ge 2 ]]; then
    REPO_DESC=$2
  else
    read -rp "Enter repository description: " REPO_DESC
  fi
fi

# Choose whether to create the repository under a user account or an organization
read -rp "Do you want to create the repository under your personal account or an organization? (p/o) " -n 1
echo ""
if [[ $REPLY =~ ^[Pp]$ ]]; then
  CREATE_PERSONAL=$GITHUB_USER
  echo "✅ Selected personal account: $CREATE_PERSONAL"
else
  read -rp "Enter organization name: " ORG_NAME
  CREATE_ORG=$ORG_NAME
  echo "✅Selected organization: $CREATE_ORG"
fi

# Confirm repository creation
read -rp "Do you want to create the repository $REPO_NAME with description '$REPO_DESC' under the selected account/organization? (y/n) " -n 1
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Check if git is initialized
  check_initialized_git

  # Check if the repository already exists
  if $GH_COMMAND api repos/"$CREATE_PERSONAL"/"$REPO_NAME" >/dev/null 2>&1; then
    read -rp "❗️ Repository $REPO_NAME already exists. Do you want to delete it and create a new one? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if ! $GH_COMMAND api repos/"$CREATE_PERSONAL"/"$REPO_NAME" -X DELETE; then
        echo "❌ Error deleting repository $REPO_NAME. Aborting."
        exit 1
      fi
    else
      echo "❌ Repository $REPO_NAME already exists. Aborting."
      exit 1
    fi
  fi

  # Create repository
  create_repository

  # Initialize local git repository
  if [[ $INITIALIZED_REPO == "" ]]; then
    if ! $GIT_COMMAND rev-parse --git-dir >/dev/null 2>&1; then
      $GIT_COMMAND init
      echo "✅ Initialized local git repository."
    else
      read -rp "❗️ Local git repository already exists. Do you want to overwrite it? (y/n) " -n 1
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        $GIT_COMMAND init
        echo "✅ Initialized local git repository."
      else
        echo "❌ Local git repository already exists. Aborting."
        exit 1
      fi
    fi
    $GIT_COMMAND add .
    $GIT_COMMAND commit -m "🎉 Initial commit"
    $GIT_COMMAND push -u origin "$BRANCH_NAME"
    echo "✅ Created initial commit and pushed to remote repository."
    INITIALIZED_REPO=true
  fi
else
  echo "❌ Repository creation aborted."
  exit 1
fi

