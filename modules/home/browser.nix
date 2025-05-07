{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    extensions = [
      # Bitwarden
      { id = "nngceckbapebfimnlniiiahkandclblb"; }

      # Refined GitHub
      { id = "hlepfoohegkhhmjieoechaddaejaokhf"; }

      # File Icons for GitHub
      { id = "ficfmibkjjnpogdcfhfokmihanoldbfe"; }
    ];
  };
}
