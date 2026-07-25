#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#nix-update --command bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

nix-update claude-code-acp --flake --use-github-releases
