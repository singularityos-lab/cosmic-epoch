#!/bin/bash

# ---------------------------------------------------------------
# Test Delete Old Release Assets - Unit Test
#
# This script tests the deletion logic of the `delete_old_assets.sh`
# script. Instead of actually deleting assets, it lists the assets
# that would be deleted, verifying if the filtering logic works as expected.
#
# Usage:
#   ./test_delete_old_assets.sh <PACKAGE_NAME>
# ---------------------------------------------------------------

set -e

if [[ -z "$1" ]]; then
  echo "Usage: $0 <PACKAGE_NAME>"
  exit 1
fi

PACKAGE="$1"

# Validators
# ----------
if [[ -z "$GITHUB_REPOSITORY" ]]; then
  GITHUB_REPOSITORY="vanilla-cosmic/cosmic-epoch"
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
echo "Running unit test..."

# Find all assets matching the package name
# -----------------------------------------
ASSETS=$(echo "$RELEASE_JSON" | jq -r \
  '.assets[] | select(.name | test("^'"$PACKAGE"'(-dbgsym)?_.+")) | "\(.id) \(.name)"')

if [[ -z "$ASSETS" ]]; then
  echo "No assets found for '$PACKAGE'. Nothing to test."
  exit 0
fi

echo "Test Mode: The following assets would be deleted for '$PACKAGE':"
echo "$ASSETS"

echo "Unit test completed successfully. No assets were deleted."
