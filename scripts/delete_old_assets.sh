#!/bin/bash

# ---------------------------------------------------------------
# Delete Old Release Assets
#
# This script removes old assets from a GitHub release based on
# a given package name. It finds all assets in the "continuous"
# release that match the package name and deletes them before
# uploading new files.
#
# Usage in GitHub Actions:
#   ./delete_old_assets.sh <PACKAGE_NAME>
#
# Note: Requires GITHUB_TOKEN to be set in the environment.
# ---------------------------------------------------------------

set -e

if [[ -z "$1" ]]; then
  echo "Usage: $0 <PACKAGE_NAME>"
  exit 1
fi

PACKAGE="$1"
GITHUB_TOKEN="$2"

# Validators
# ----------
if [[ -z "$GITHUB_REPOSITORY" ]]; then
  GITHUB_REPOSITORY="vanilla-cosmic/cosmic-epoch"
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Error: GITHUB_TOKEN is not set. Make sure to run this script in a GitHub Actions environment."
  exit 1
fi

# Fetch the release details for the 'continuous' release
# ------------------------------------------------------
echo "Fetching release details for 'continuous' in repo $GITHUB_REPOSITORY..."
RELEASE_JSON=$(curl -s \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/continuous")

if [[ -z "$RELEASE_JSON" || "$(echo "$RELEASE_JSON" | jq -r .message)" == "Not Found" ]]; then
  echo "Error: Release 'continuous' not found!"
  exit 1
fi

echo "Release details fetched successfully."

# Find all assets matching the package name
# -----------------------------------------
ASSETS=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | startswith("'"$PACKAGE"'")) | "\(.id) \(.name)"')

if [[ -z "$ASSETS" ]]; then
  echo "No assets found for '$PACKAGE'. Nothing to delete."
  exit 0
fi

echo "Found old assets for '$PACKAGE':"
echo "$ASSETS"

# Delete matching assets
# -----------------------
while read -r ASSET_ID ASSET_NAME; do
  echo "Deleting asset: $ASSET_NAME (ID: $ASSET_ID)..."
  curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/assets/$ASSET_ID"
  echo "Deleted: $ASSET_NAME"
done <<< "$ASSETS"

echo "Cleanup complete. All old assets removed for '$PACKAGE'."
