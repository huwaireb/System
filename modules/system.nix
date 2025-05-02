{ pkgs, lib, ... }:
let
  inherit (lib)
    last
    mkOption
    splitString
    ;
in
{
  options = {
    os = mkOption {
      default = last <| splitString "-" pkgs.stdenv.hostPlatform.system;
      readOnly = true;
    };

    isLinux = mkOption {
      default = pkgs.stdenv.hostPlatform.isLinux;
      readOnly = true;
    };

    isDarwin = mkOption {
      default = pkgs.stdenv.hostPlatform.isDarwin;
      readOnly = true;
    };
  };
}
