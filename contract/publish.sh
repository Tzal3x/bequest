#!/bin/zsh

sui client publish --json > .publish.json

export ADMIN_CAP=$(cat contract/.publish.json | jq -r '.objectChanges[] | select(.type == "created") | select(.objectType | contains("AdminCap")) | .objectId')
export PACKAGE_ID=$(cat contract/.publish.json | jq -r '.objectChanges[] | select(.type == "published") | .packageId')
export LAST_CHECKIN=$(cat contract/.publish.json | jq -r '.objectChanges[] | select(.type == "created") | select(.objectType | contains("LastCheckIn")) | .objectId')

if [[ -z "$ADMIN_CAP" || -z "$PACKAGE_ID" || -z "$LAST_CHECKIN" ]]; then
    echo "Something went wrong publishing the contract." >&2
    exit 1
fi

echo "Contract published successfully ✔️"
echo "ADMIN_CAP: $ADMIN_CAP"
echo "PACKAGE_ID: $PACKAGE_ID"
echo "LAST_CHECKIN: $LAST_CHECKIN"
