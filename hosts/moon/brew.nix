{
  homebrew = {
    enable = true;

    global.brewfile = true;

    masApps.Xcode = 497799835;
    masApps.parallels = 1085114709;

    brews = [ "esphome" ];

    casks = [
      # For some reason needs to update on every open when downloaded using nixpkgs
      "discord"

      # Gets outdated real quick, still looking for a better FOSS alternative.
      "raycast"

      # See modules/home/ghostty.nix. TL;DR Requires Xcode to build
      "ghostty"

      # The MacOS version of WhatsApp in nixpkgs, "whatsapp-for-mac"
      # fails to download with a 404.
      "whatsapp"

      # Not in nixpkgs
      "autodesk-fusion"

      # Not in nixpkgs
      "cleanshot"

      # Breaks in nixpkgs
      "zed@preview"
    ];
  };
}
