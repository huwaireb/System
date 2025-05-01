{
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
{
  imports = [
    ./helix.nix
    ./vcs.nix
  ];

  home.packages = with pkgs; [
    pciutils

    nixfmt-rfc-style

    sqlite

    fd
    ripgrep
    eza
    sad
    tealdeer
    jq
    glow

    watchman
    difftastic

    nixd
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      color = "always";
    };
  };

  programs.zoxide = {
    enable = true;
    package = pkgs.zoxide;
    options = [ "--cmd cd" ];
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--ansi"
      "--preview-window 'right:60%'"
      "--preview bat"
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.nushell = {
    enable = true;
    configFile.text = readFile ../../config/nu/config.nu;
  };

  xdg.configFile = {
    "nushell/zoxide.nu".source = pkgs.runCommand "zoxide.nu" { } ''
      ${getExe pkgs.zoxide} init nushell --cmd cd > $out
    '';

    "nushell/ls_colors.txt".source = pkgs.runCommand "ls_colors.txt" { } ''
      ${getExe pkgs.vivid} generate gruvbox-dark-hard > $out
    '';

    "nushell/starship.nu".source = pkgs.runCommand "starship.nu" { } ''
      ${getExe pkgs.starship} init nu > $out
    '';
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "gruvbox";
        src = pkgs.fishPlugins.gruvbox;
      }
    ];

    shellInit = ''
      set fish_greeting
    '';

    shellAliases = {
      cat = "bat";
      ls = "eza";
    };
  };

  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
