#!/usr/bin/env nix
#!nix shell --ignore-environment nixpkgs#cacert nixpkgs#coreutils nixpkgs#curl nixpkgs#jq nixpkgs#bash --command bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Same per-platform manifests that upstream's install.sh
# (https://antigravity.google/cli/install.sh) resolves the binary from.
BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"

# Keep in sync with `platformKey` in package.nix.
PLATFORMS=(linux_amd64 linux_arm64 darwin_amd64 darwin_arm64)

for platform in "${PLATFORMS[@]}"; do
  curl -fsSL "$BASE_URL/$platform.json" | jq --arg platform "$platform" '{($platform): .}'
done | jq -s '
  add as $p
  | ($p | map(.version) | unique) as $versions
  | if ($versions | length) != 1 then error("platforms disagree on version: \($versions)") else . end
  | { version: $versions[0], platforms: ($p | map_values({ url, sha512 })) }
' >manifest.json.tmp

mv manifest.json.tmp manifest.json
echo "antigravity-cli: $(jq -r .version manifest.json)"
