#!/bin/sh -l

set -e # if a command fails it stops the execution
set -u # script fails if trying to access to an undefined variable

echo "Starting deploy"

echo "Installing gems"
bundle config path vendor/bundle
bundle install
echo "Gems installed"

echo "Jekyll building"
bundle exec jekyll build
echo "Jekyll build done"

# clone down current site repo
SOURCE_DIRECTORY="$1"
DESTINATION_GITHUB_USERNAME="$2"
DESTINATION_REPOSITORY_NAME="$3"
USER_EMAIL="$4"
DESTINATION_REPOSITORY_USERNAME="$5"
TARGET_BRANCH="$6"
DEPLOYMENT_FILES_DIR="$7"
COMMIT_MESSAGE="$8"

if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
then
	DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$DESTINATION_GITHUB_USERNAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

# rm all non git dir files in the clone_dir
echo "Cleaning destination repository of old files"
find "$CLONE_DIR" | grep -v "^$CLONE_DIR/\.git" | grep -v "^$CLONE_DIR$" | xargs rm -rf # delete all files (to handle deletions)
ls -la "$CLONE_DIR"

# copy all files from the _site dir to the clone_dir
echo "Copying contents to git repo"
cp -r "$SOURCE_DIRECTORY"/* "$CLONE_DIR"
if [ -n "$DEPLOYMENT_FILES_DIR" ]
then
	cp -r "$DEPLOYMENT_FILES_DIR"/* "$CLONE_DIR"
fi
cd "$CLONE_DIR"
ls -la

# then do git add/commit/push process
echo "Adding git commit"

if [ -z "$COMMIT_MESSAGE" ]
then
	COMMIT_MESSAGE="Committed from: https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
fi

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$TARGET_BRANCH"

echo "Ending deploy"