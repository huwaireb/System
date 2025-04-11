{
  self,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "rmu";
    computerName = "mbp23";
  };

  users.users.rmu = {
    description = "Rashid Almheiri";
    home = "/Users/rmu";
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    taps = [ "d12frosted/emacs-plus" ];
    casks = [ "raycast" ];
    brews = [ "emacs-plus" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.rmu = {
    _module.args = {
      inherit self inputs lib;
    };

    imports = [
      ../../profiles/platform._
      ../../profiles/platform._/apps.nix
      ../../profiles/platform.darwin
    ];
  };
}
