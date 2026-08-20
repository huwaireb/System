#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#coreutils nixpkgs#curl --command bash

set -euo pipefail

# Keep these in sync with `platform` in package.nix.
platforms() {
  cat <<'EOF'
x86_64-linux linux-x86_64
aarch64-linux linux-aarch64
aarch64-darwin macos-aarch64
EOF
}

package_nix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package.nix"

prefetch_sri() {
  local url="$1"
  local raw_hash
  raw_hash="$(nix-prefetch-url --type sha256 "$url")"
  nix hash convert --to sri --hash-algo sha256 "$raw_hash"
}

replace_assignment() {
  local key="$1"
  local value="$2"
  local pattern="$3"
  if ! grep -qE "^[[:space:]]*${key} = \"${pattern}" "$package_nix"; then
    echo "error: could not find ${key} in ${package_nix}" >&2
    exit 1
  fi
  sed -i -E "s|^([[:space:]]*${key} = \")${pattern}[^\"]*(\";)|\1${value}\2|" "$package_nix"
}

version="${1:-$(curl -fsSL https://x.ai/cli/stable)}"
version="$(printf '%s' "$version" | tr -d '[:space:]')"

current_version="$(sed -n 's/^[[:space:]]*version = "\(.*\)";/\1/p' "$package_nix" | head -n1)"

if [[ -z "$current_version" ]]; then
  echo "error: could not read version from ${package_nix}" >&2
  exit 1
fi

if [[ "$current_version" == "$version" ]]; then
  echo "package is up-to-date: ${version}"
  exit 0
fi

echo "updating grok-build: ${current_version} -> ${version}"

hashes="$(mktemp)"
trap 'rm -f "$hashes"' EXIT

while read -r system platform; do
  url="https://x.ai/cli/grok-${version}-${platform}"
  echo "prefetching ${system} (${url})"
  printf '%s %s\n' "$system" "$(prefetch_sri "$url")" >>"$hashes"
done < <(platforms)

replace_assignment version "$version" "$current_version"

while read -r system hash; do
  replace_assignment "$system" "$hash" "sha256-"
done <"$hashes"

echo "updated ${package_nix} to ${version}"
