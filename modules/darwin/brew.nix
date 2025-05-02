{
  homebrew = {
    enable = true;
    casks = [
      "stats"
      "ghostty" # not available on nixpkgs for macos
      "raycast"
      "whatsapp" # whatsapp-for-macos gives a 404 when downloading the app
    ];
  };
}
