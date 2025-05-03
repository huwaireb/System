{
  homebrew = {
    enable = true;
    casks = [
      # For some reason needs to update on every open when downloaded using nixkpgs
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
