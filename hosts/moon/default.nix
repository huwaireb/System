{ pkgs, ... }:
let
  inherit (pkgs) fish;
in
{
  imports = [ ./brew.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking = {
    hostName = "rmu";
    computerName = "moon";
  };

  home-manager.users.rmu = import ./home.nix;

  system.primaryUser = "rmu";
  users.users.rmu = {
    description = "Rashid Almheiri";
    home = "/Users/rmu";
    shell = fish;
  };

  system = {
    stateVersion = 5;
    defaults.dock.persistent-apps = [
      { app = "/Applications/Dia.app"; }
      { app = "/System/Applications/Music.app"; }

      { app = "/Applications/Ghostty.app"; }
      { app = "${pkgs.zed-editor}/Applications/Zed.app"; }
      { app = "/Applications/Xcode-beta.app/"; }

      { app = "/Applications/Discord.app"; }
      { app = "/Applications/WhatsApp.app"; }
    ];
  };
}
