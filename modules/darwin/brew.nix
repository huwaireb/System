{
  homebrew = {
    enable = true;
    casks = [
      # See modules/home/ghostty.nix. TL;DR Requires Xcode to build
      "ghostty"

      # The MacOS version of WhatsApp in nixpkgs, "whatsapp-for-mac"
      # fails to download with a 404.
      "whatsapp"
    ];
  };
}
