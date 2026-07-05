{ lib, pkgs, config, ... }:
let
  cfg = config.ai;
in
lib.mkIf cfg.pi.enable {
  # Stow-style writable symlinks so pi can write auth.json, skill toggles,
  # node_modules, and lock files through the link into the repo working tree.
  home.file.".pi".source = config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/pi";
  home.file.".agents".source = config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/agents";

  # pi extensions are an npm workspace; install deps after activation.
  home.activation.piExtensions =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${cfg.configRoot}/pi/package.json" ]; then
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install \
          --prefix "${cfg.configRoot}/pi" --no-audit --no-fund || \
          echo "pi extension npm install failed; run 'npm install' in ~/.pi manually"
      fi
    '';
}
