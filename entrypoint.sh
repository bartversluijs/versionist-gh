#!/bin/bash
set -e

# get_version: gets the current project version based on repository files. File priority is:
# - VERSION file
# - package.json file
# - defaults to v0.0.1 if previous files not present
function get_version () {
  local VERSION=0.0.1

  if [[ -f VERSION ]]; then
    VERSION="$(cat VERSION)"
  elif [[ -f package.json ]]; then
    VERSION="$(jq -r .version package.json)"
  fi

  echo "$VERSION"
}

# check_required_inputs: checks for required inputs, exits if not present
function check_required_inputs () {
  if [[ -z "$INPUT_COMMIT" ]]; then
    echo "ERROR: INPUT_COMMIT is required!"
    exit 1
  fi

  if [[ -z "$DRY_RUN" ]] && [[ $INPUT_COMMIT == "true" ]]; then
    if [[ -z "$INPUT_GITHUB_EMAIL" ]]; then
      echo "ERROR: INPUT_GITHUB_EMAIL is required!"
      exit 1
    fi

    if [[ -z "$INPUT_GITHUB_USERNAME" ]]; then
      echo "ERROR: INPUT_GITHUB_USERNAME is required!"
      exit 1
    fi

    if [[ -z "$INPUT_GITHUB_TOKEN" ]]; then
      echo "ERROR: INPUT_GITHUB_TOKEN is required!"
      exit 1
    fi
  fi
}

# create_tag_if_not_exists: creates an annotated tag for the given version if it does not exist
function create_tag_if_not_exists () {
  local VERSION=$1
  local CHECK_TAG_EXISTS=$(git tag | grep "$VERSION")
  if [[ -z "$CHECK_TAG_EXISTS" ]]; then
    echo "Tag for $VERSION not found. Creating it..."
    git tag -a "$VERSION" -m "$VERSION"
  fi
}

# run_versionist: run versionist
function run_versionist () {
  local CURRENT_VERSION="v$(get_version)"

  echo "Running versionist..."
  echo "Current version: $CURRENT_VERSION"

  if [[ $COMMIT_CHANGES == "true" ]]; then
    # Setup GitHub
    git config --local user.email "$INPUT_GITHUB_EMAIL"
    git config --local user.name "$INPUT_GITHUB_USERNAME"

    # Create tag for current version if it doesn't exist
    TAG_CREATED=$(create_tag_if_not_exists "$CURRENT_VERSION")
  fi

  # Run versionist
  versionist $@
  local NEW_VERSION="v$(get_version)"
  echo "New version: $NEW_VERSION"

  if [[ $COMMIT_CHANGES == "true" ]]; then
    # Commit and push changes
    git add .
    git commit -m "$NEW_VERSION"
    create_tag_if_not_exists "$NEW_VERSION"
    if [[ -z $DRY_RUN ]]; then
      git push "${REPO_URL}" HEAD:${INPUT_BRANCH} --follow-tags
    fi
  fi

  # Set environment files
  echo "version=$(get_version)" >> $GITHUB_OUTPUT
  echo "updated=true" >> $GITHUB_OUTPUT
}

# Defaults
INPUT_BRANCH=${INPUT_BRANCH:-$GITHUB_REF}
COMMIT_CHANGES=${INPUT_COMMIT:-false}
REPO_URL="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# development: Dry run when running in development
if [[ $GITHUB_ACTOR == "nektos/act" ]]; then
  DRY_RUN="--dry-run"
fi

# Initialize
check_required_inputs

echo "--- Versionist ---"
[[ -n "$DRY_RUN" ]] && echo "Running in dry run mode: no actions will be commited."
echo "Current version: v$(get_version)"

# Only show when versionist changes are going to be comitted
if [[ $COMMIT_CHANGES == "true" ]]; then
  echo "Commiting changes: Yes"
  echo "Repository branch: $INPUT_BRANCH"
  echo "GitHub user: $INPUT_GITHUB_USERNAME"
  echo "GitHub email: $INPUT_GITHUB_EMAIL"
  echo "GitHub token: ok!"
else
  echo "Commiting changes: No"
fi

# Set environment files
echo "version=$(get_version)" >> $GITHUB_OUTPUT
echo "updated=false" >> $GITHUB_OUTPUT

run_versionist $@
