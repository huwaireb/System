{ lib, config, ... }:
let
  cfg = config.ai;
in
lib.mkIf cfg.pi.enable {
  # Stow-style writable symlinks so pi can write auth.json, skill toggles,
  # node_modules, and lock files through the link into the repo working tree.
  # (pi is a stateful, self-managing tool — this boundary is intentional; Nix
  # provides the binary, pi owns its runtime state under ~/.pi.)
  home.file.".pi".source = config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/pi";
  home.file.".agents".source = config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/agents";

  # Expose pi package CLIs (e.g. hypa, used by pi-hypa's bash rewrite) on PATH so
  # pi's bash tool can invoke them. This is pi's npm package-bin dir (via ~/.pi).
  # Done via fish directly: fish doesn't source hm-session-vars.sh, so
  # home.sessionPath wouldn't reach the shell that launches pi.
  programs.fish.shellInit = ''
    fish_add_path --global --prepend "${config.home.homeDirectory}/.pi/agent/npm/node_modules/.bin"
  '';
}
