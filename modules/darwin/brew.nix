{
  homebrew = {
    enable = true;
    
    global.brewfile = true;

    # Get Xcode Apple Store
    masApps.Xcode = 497799835;

    taps = [ "d12frosted/emacs-plus" ];
    brews = [
      # NativeComp is broken in nixpkgs for darwin 15.4
      {
        name = "emacs-plus@31";
        args = [ "with-imagemagick" ];
        start_service = true;
        restart_service = true;
      }
    ];

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
    ];
  };
}
