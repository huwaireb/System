{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.ai;
in
lib.mkIf cfg.herdr.enable {
  home.packages = [
    pkgs.herdr.overrideAttrs
    (_: rec {
      version = "0.9.3";

      src = pkgs.fetchFromGitHub {
        owner = "herdrdev";
        repo = "herdr";
        tag = "v${version}";
        hash = "sha256-uu452Xe23pSvFk7w7fKPjiaqY5QenUIljao2SFAxpc0=";
      };

      cargoHash = "sha256-+gTWtEheyuI59yf2PqRbcbcFIW+/cYb7zZ2mPv2VN0Y=";
    })
  ];

  # Writable symlink: `herdr config reset-keys` / `server reload-config` rewrite this file.
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/herdr/config.toml";
}
