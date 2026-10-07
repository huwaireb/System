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
    (pkgs.herdr.overrideAttrs (prev: rec {
      version = "0.9.3";

      # Avoid ld.bfd rejecting overlapping unwind records from the Ghostty build.
      nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ pkgs.lld ];
      env = (prev.env or { }) // {
        NIX_CFLAGS_LINK = lib.concatStringsSep " " [
          (prev.env.NIX_CFLAGS_LINK or "")
          "-fuse-ld=lld"
        ];
      };

      src = pkgs.fetchFromGitHub {
        owner = "herdrdev";
        repo = "herdr";
        tag = "v${version}";
        hash = "sha256-uu452Xe23pSvFk7w7fKPjiaqY5QenUIljao2SFAxpc0=";
      };

      cargoHash = "sha256-+gTWtEheyuI59yf2PqRbcbcFIW+/cYb7zZ2mPv2VN0Y=";
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (prev) pname;
        inherit version src;
        hash = cargoHash;
      };
    }))
  ];

  # Writable symlink: `herdr config reset-keys` / `server reload-config` rewrite this file.
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/herdr/config.toml";
}
