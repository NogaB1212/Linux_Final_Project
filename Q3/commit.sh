#!/usr/bin/env bash

################################################################################
# 1) Setup variables and validations
################################################################################

XL_FILE="bugs.csv"  # Name of the CSV file in the same directory
OPTIONAL_param=$1     # Optional developer extra note from command-line arg

# Check if CSV file exists in the same dir as the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ ! -f "$SCRIPT_DIR/$XL_FILE" ]]; then
  echo "ERROR: CSV file '$XL_FILE' not found in the script directory!"
  exit 1
fi

cd "$SCRIPT_DIR"  # Ensure we run inside the script's directory (contains CSV)

################################################################################
# 2) Get current branch and locate row in CSV
################################################################################

CURRENT_BRANCH="$(git branch --show-current)"

# Try to find the line in the CSV matching the branch name in the 3rd column
LINE="$(grep ",$CURRENT_BRANCH," "$XL_FILE" || true)"
# '|| true' prevents grep from exiting non-zero if no match.

if [[ -z "$LINE" ]]; then
  echo "ERROR: No matching line in '$XL_FILE' for branch '$CURRENT_BRANCH'."
  exit 1
fi

################################################################################
# 3) Parse the CSV line into variables
################################################################################

# Assuming columns in this order:
# BUGID,DESCRIPTION,BRANCH,DEVELOPER_NAME,BUG_PRIORITY,REPOSITORY_PATH,GITHUBURL
IFS=',' read -r BUGID DESCRIPTION BRANCH DEV_NAME BUG_PRIORITY REPO_PATH GITHUBURL <<< "$LINE"

# Confirm we got something
if [[ -z "$BUGID" || -z "$DESCRIPTION" || -z "$BRANCH" ]]; then
  echo "ERROR: Missing fields in CSV. Check format."
  exit 1
fi

################################################################################
# 4) Build the commit message
################################################################################

# Current date/time in a suitable format
CURRENT_DATETIME="$(date +%Y-%m-%d_%H-%M)"

# Format: BugID:CurrentDateTime:BranchName:DevName:Priority:Description:{optional}
COMMIT_MESSAGE="$BUGID:$CURRENT_DATETIME:$BRANCH:$DEV_NAME:$BUG_PRIORITY:$DESCRIPTION"

# If user provided an extra note, append it
if [[ -n "$OPTIONAL_param" ]]; then
  COMMIT_MESSAGE="$COMMIT_MESSAGE:$OPTIONAL_param"
fi

echo "Using commit message:"
echo "  $COMMIT_MESSAGE"

################################################################################
# 5) Git add, commit, and push
################################################################################

# Optionally add only specific files if you don't want to commit everything.
echo "Staging changes..."
git add .

echo "Committing changes..."
# Capture commit errors
if ! git commit -m "$COMMIT_MESSAGE" 2> commit_err.log; then
  echo "ERROR: Git commit failed. Check commit_err.log for details."
  exit 1
fi

echo "Pushing to GitHub..."
# Capture push errors
if ! git push origin "$CURRENT_BRANCH" 2> push_err.log; then
  echo "ERROR: Git push failed. Check push_err.log for details."
  exit 1
fi

################################################################################
# 6) Done
################################################################################

echo "SUCCESS: Changes committed and pushed on branch '$CURRENT_BRANCH'."
exit 0