#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN

        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
}

is_defined() {
    [ ! -z "${1}" ]
}

# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! git diff --quiet
then
    git_setup

    echo "INPUT_BRANCH value: $INPUT_BRANCH";

    # Switch to branch from current Workflow run
    git checkout $INPUT_BRANCH

    if is_defined "${INPUT_FILE_PATTERN}"; then
        echo "INPUT_FILE_PATTERN: ${INPUT_FILE_PATTERN}"

        git add "${INPUT_FILE_PATTERN}"
    else
        git add .
    fi

    if is_defined "${INPUT_COMMIT_OPTIONS}"; then
        echo "INPUT_FILE_PATTERN: ${INPUT_COMMIT_OPTIONS}"

        git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>" "${INPUT_COMMIT_OPTIONS}"
    else
        git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>"
    fi

    git push --set-upstream origin "HEAD:$INPUT_BRANCH"
else
    echo "Working tree clean. Nothing to commit."
fi
