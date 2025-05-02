{ pkgs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.rmu = {
    description = "Rashid Almheiri";
    home = if pkgs.stdenv.isDarwin then "/Users/rmu" else "/home/rmu";
    shell = pkgs.fish;
  };
}
