{ pkgs, ... }:
{
  imports = [
    ./shell.nix
    ./vcs.nix
  ];

  home.packages = with pkgs; [
    pciutils

    nixfmt-rfc-style

    sqlite

    fd
    ripgrep

    jq

    watchman

    nixd
  ];

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--ansi"
      "--preview-window 'right:60%'"
    ];
  };

  programs.z-lua = {
    enable = true;
    enableFishIntegration = true;
    enableAliases = true;
    options = [
      "enhanced"
      "fzf"
      "once"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
