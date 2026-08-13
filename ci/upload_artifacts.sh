#!/usr/bin/env bash

set -euv -o pipefail
export PATH="/usr/bin:$PATH"

BRANCH_NAME="${CI_BRANCH_NAME#refs/heads/}"

cd ./artifacts

BASENAME=$(echo "$BRANCH_NAME" | sed -e 's/[^A-Za-z0-9_-]/_/g')
BASENAME+="~$(date +%s)"

if [[ -n "${UPLOAD_SIGN_KEY:-}" ]]; then
  openssl dgst -sha256 -sign <(printf '%s\n' "$UPLOAD_SIGN_KEY") \
    -out ./artifacts.tar.sha256 ./artifacts.tar
  tar -cjf "./$BASENAME.tbz2" ./artifacts.tar.sha256 ./artifacts.tar
else
  echo "UPLOAD_SIGN_KEY not set; uploading unsigned artifact tarball."
  tar -cjf "./$BASENAME.tbz2" ./artifacts.tar
fi

curl --fail --basic -u "$UPLOAD_USER:$UPLOAD_PASS" -F "path=@$BASENAME.tbz2" "$UPLOAD_URL"
