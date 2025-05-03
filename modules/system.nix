{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv) hostPlatform;
  inherit (lib) mkOption;

  mkConst =
    default:
    mkOption {
      inherit default;
      readOnly = true;
    };
in
{
  options = {
    isLinux = mkConst hostPlatform.isLinux;
    isDarwin = mkConst hostPlatform.isDarwin;
  };
}
