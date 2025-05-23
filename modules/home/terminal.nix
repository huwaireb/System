{ config, pkgs, ... }:
let
  is-desktop = config.type == "desktop";
in
{
  home.packages =
    with pkgs;
    [
      sqlite

      fd
      ripgrep

      jq

      pandoc
    ]
    ++ lib.optionals is-desktop [
      nixd
      nixfmt-rfc-style
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
    enable = is-desktop;
    nix-direnv.enable = true;
  };
}
