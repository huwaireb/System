{ pkgs, config, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.rmu = {
    description = "Rashid Almheiri";
    home = if config.isDarwin then "/Users/rmu" else "/home/rmu";
    shell = pkgs.fish;
  };
}
