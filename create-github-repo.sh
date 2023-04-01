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

# Check if the user is logged in to the gh CLI
echo "${ROCKET} Checking if user is logged in to gh CLI..."
if ! gh auth status > /dev/null 2>&1; then
  echo "${PROMPT} User is not logged in to gh CLI. Please log in using the command: gh auth login"
  read -p "Press enter to continue..."
  if ! gh auth login; then
    echo "${ERROR} Unable to log in to gh CLI. Please try again or check your credentials."
    exit 1
  fi
fi

# Choose where to create the repository
echo "${PROMPT} Where would you like to create the repository?"
echo "1) Under your personal account"
echo "2) Under an organization"
read REPLY
# Create the repository
if [ "$REPLY" = "1" ]; then
  GH_CREATE_CMD="gh repo create $GITHUB_USER/$REPO_NAME -d \"$REPO_DESC\" --public"
else
  echo "${PROMPT} Please enter the name of the organization:"
  read ORG_NAME
  GH_CREATE_CMD="gh repo create $ORG_NAME/$REPO_NAME -d \"$REPO_DESC\" --public -p"
fi
echo "${ROCKET} Creating repository $REPO_NAME..."
OUTPUT=$(eval "$GH_CREATE_CMD" 2>&1)
if [[ $OUTPUT =~ "Invalid repository name" ]]; then
  echo "${ERROR} Invalid repository name. Please choose a different name."
  exit 1
elif [[ $OUTPUT =~ "permission to create repository" ]]; then
  echo "${ERROR} You do not have permission to create repositories in the selected account or organization. Please try again with a different account or organization, or ask an administrator to grant you permission."
  exit 1
elif [[ $OUTPUT =~ "requires authentication" ]]; then
  echo "${ERROR} Authentication failed. Please check your credentials and try again."
  exit 1
elif [[ $OUTPUT =~ "Validation Failed" ]]; then
  echo "${ERROR} An error occurred while creating the repository. Please check the repository name and description for invalid characters, or try again later."
  exit 1
elif [[ $OUTPUT =~ "remote repository already exists" ]]; then
  echo "${STAR} Remote repository already exists. Skipping repository creation."
else
  echo "${STAR} Repository $REPO_NAME created successfully!"
  REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME"
  echo "${STAR} You can view your new repository here: $REPO_URL"
fi

# Initialize Git repository
# Check if the project directory is a Git repository
echo "${ROCKET} Checking if project directory is a Git repository..."
if [ -d "$PROJECT_PATH" ]; then
  cd "$PROJECT_PATH"
fi
if [ -d ".git" ]; then
  echo "${PROMPT} $PROJECT_PATH is already a Git repository. Do you want to use the existing repository?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes )
        echo "${ROCKET} Using existing Git repository at $PROJECT_PATH."
        # Check if the Git repository has a remote
        if git remote get-url origin > /dev/null 2>&1; then
          echo "${STAR} Git remote already exists. Skipping remote setup."
        else
          echo "${ROCKET} Setting up Git remote..."
          git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
        fi
        # Commit and push changes
        git add .
        git commit -m "${PENCIL} Initial commit 🎉"
        git push -u origin main
        break;;
      No )
        echo "${ROCKET} Initializing new Git repository..."
        git init
        git add .
        git commit -m "${PENCIL} Initial commit 🎉"
        # Set up remote
        echo "${ROCKET} Setting up Git remote..."
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
        git push -u origin main
        break;;
    esac
  done
else
  echo "${ROCKET} Initializing new Git repository..."
  git init
  git add .
  git commit -m "${PENCIL} Initial commit 🎉"
  # Set up remote
  echo "${ROCKET} Setting up Git remote..."
  git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
  git push -u origin main
fi

exit 0