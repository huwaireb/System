{ lib, pkgs, config, ... }:
let
  cfg = config.ai;
in
lib.mkIf cfg.herdr.enable {
  home.packages = [ pkgs.herdr ];

  # Writable symlink: `herdr config reset-keys` / `server reload-config` rewrite this file.
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/herdr/config.toml";
}
