# automate-me
A repository containing a collection of scripts to automate common tasks.
## create-github-repo.sh
A script that automates the creation of a new GitHub repository.
### Usage
```bash
./create-github-repo.sh [optional_path_to_local_repo]
```
### Dependencies
* jq
* GitHub CLI (gh)
### Functionality
The script does the following:
1. Checks that the required dependencies are installed
2. Checks that the user is logged in to GitHub using the `gh auth status` command
3. Prompts the user for the repository name and description if they are not provided as arguments
4. Checks if the repository name is available on GitHub
5. Initializes a new local Git repository
6. Creates a new public GitHub repository with the given name and description using the `gh repo create` command
7. Adds the GitHub repository as a remote and pushes the local Git repository to the remote
### Example
To create a new repository with the name `my-new-repo` and the description `My new repository` in the current directory (*):
```bash
./create-github-repo.sh
```
To create a new repository with the name `my-new-repo` and the description `My new repository` in the directory `/path/to/repo` (*):
```bash
./create-github-repo.sh /path/to/repo
```

(*) considering your package.json contains the repo name and description inside

### Credits
This script was created by [adico1](https://github.com/adico1).
