{ config, pkgs, ... }:
let
  is-desktop = config.type == "desktop";
in
{
  programs.chromium = {
    enable = is-desktop;
    package = pkgs.brave;
    extensions = [
      # Bitwarden
      { id = "nngceckbapebfimnlniiiahkandclblb"; }

      # Refined GitHub
      { id = "hlepfoohegkhhmjieoechaddaejaokhf"; }

      # File Icons for GitHub
      { id = "ficfmibkjjnpogdcfhfokmihanoldbfe"; }

      # Surfingkeys
      { id = "gfbliohnnapiefjpjlpjnehglfpaknnc"; }
    ];
  };
}
