lib:
lib.darwinSystem' (
  { pkgs, ... }:
  {
    imports = [
      ../../modules/home.nix
      ../../modules/darwin/brew.nix
    ];

    nixpkgs.hostPlatform = "aarch64-darwin";

    networking.hostName = "rmu";
    networking.computerName = "moon";

    home-manager.users.rmu.imports = [
      ../../modules/home
      ../../modules/home/ghostty.nix
      ../../modules/home/emacs.nix
      ../../modules/home/browser.nix
      ../../modules/home/activation/wallpaper/default.nix    
    ];

    system.defaults.dock.persistent-apps = [
      { app = "${pkgs.brave}/Applications/Brave Browser.app"; }
      { app = "/System/Applications/Music.app"; }

      { app = "/Applications/Ghostty.app"; }
      { app = "${pkgs.emacs}/Applications/Emacs.app"; }
      { app = "/Applications/Xcode.app"; }

      { app = "/Applications/Discord.app"; }
      { app = "/Applications/WhatsApp.app"; }

      { folder = "/Users/rmu/Projects"; }
    ];

    system.stateVersion = 5;
  }
)
