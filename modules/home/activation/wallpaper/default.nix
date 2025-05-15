{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) hm;
  wallpaper = ../../config/wallpaper.jpg;
  setWallpaper =
    let
      inherit (pkgs) stdenv apple-sdk;
    in
    stdenv.mkDerivation {
      pname = "set-wallpaper";
      version = "0.1.0";
      src = ./setter.m;

      dontUnpack = true;
      buildInputs = [ apple-sdk ];

      buildPhase = ''
        clang -fobjc-arc -fmodules -framework Foundation -framework AppKit \
              -o SetWallpaper $src
      '';

      installPhase = ''
        install -Dm 755 SetWallpaper $out/bin/SetWallpaper
      '';
    };
in
{
  home.activation.setWallpaper = hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${setWallpaper}/bin/SetWallpaper "${wallpaper}"
  '';
}
