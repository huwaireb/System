{ pkgs, ... }:
{
  programs.zsh.enable = true;
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      set fish_key_bindings fish_vi_key_bindings 
      fish_config theme choose tokyonight
    '';
  };

  xdg.configFile."fish/themes/tokyonight.theme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/refs/tags/v4.11.0/extras/fish_themes/tokyonight_night.theme";
    sha256 = "yabv/At93pvL3Kp/H4XGn8YHd5zfsNsOlktj5iUx3AM=";
  };
}
