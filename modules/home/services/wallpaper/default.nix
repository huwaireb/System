{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs) stdenv;
  inherit (lib) hm types;

  cfg = config.services.wallpaper;
  setWallpaper = pkgs.callPackage ./package.nix { };
in
{
  options.services.wallpaper = {
    enable = lib.mkEnableOption "Wallpaper setting service";
    path = lib.mkOption {
      type = types.path;
      description = "Path to the wallpaper image";
      example = ./wallpaper.jpg;
    };
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    home.activation.setWallpaper = hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${lib.getExe setWallpaper} "${cfg.path}"
    '';
  };
}
