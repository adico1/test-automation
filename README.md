# Automate-Me

Automate-Me is a collection of scripts to automate common tasks. Currently, it contains one script:

- `create-github-repo.sh`: Creates a new repository on GitHub and initializes it with a local Git repository.

## Installation

To use the `create-github-repo.sh` script, you'll need to have the following dependencies installed:

- `jq`
- The GitHub CLI (`gh`)

If you don't already have these dependencies installed, please install them before continuing.

To install the `create-github-repo.sh` script, you can clone this repository and copy the script to a directory that's in your system's `PATH` environment variable. For example:

```sh
git clone https://github.com/adico1/automate-me.git
cd automate-me
chmod +x create-github-repo.sh
sudo cp create-github-repo.sh /usr/local/bin
```

This will copy the `create-github-repo.sh` script to the `/usr/local/bin` directory, which is typically included in the PATH environment variable on most systems.

Once the script is installed, you can run it from any directory by typing `create-github-repo.sh`.

## Usage
To use the `create-github-repo.sh` script, simply run it from a directory that you'd like to initialize as a Git repository:
```sh
create-github-repo.sh
```
The script will prompt you for the name of the new repository and a description (optional). It will then create a new repository on GitHub, initialize a local Git repository in the current directory, and push the local repository to the remote repository on GitHub.

If you'd like to specify the name of the new repository as a command-line argument, you can do so:
```sh
create-github-repo.sh my-new-repo
```
This will create a new repository on GitHub with the name my-new-repo.

That's it! If you encounter any issues or have any questions, please feel free to open an issue on this repository.
