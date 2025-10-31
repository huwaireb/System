{
  config,
  lib,
  ...
}:

{
  imports = [ ./system.nix ];

  time.timeZone = lib.mkDefault "Asia/Dubai";

  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ { inherit (config) type; } ];
  };
}
