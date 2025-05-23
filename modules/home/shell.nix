{ pkgs, ... }:
{
  xdg.configFile."fish/themes/tokyonight.theme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/refs/tags/v4.11.0/extras/fish_themes/tokyonight_night.theme";
    sha256 = "yabv/At93pvL3Kp/H4XGn8YHd5zfsNsOlktj5iUx3AM=";
  };

  programs.fish = {
    enable = true;

    shellAliases.x = "$EDITOR";
    shellInit = ''
      set fish_greeting
      set fish_key_bindings fish_vi_key_bindings
      fish_config theme choose tokyonight
    '';

    functions.fish_mode_prompt = ""; # Set in fish_prompt
    functions.fish_prompt = ''
      set -l normal (set_color normal)
      set -l cyan (set_color --bold cyan)
      set -l green (set_color --bold green)
      set -l red (set_color --bold red)
      set -l blue (set_color --bold blue)
      set -l magenta (set_color --bold magenta)
      set -l yellow (set_color --bold yellow)

      set -l current_dir "$cyan"(prompt_pwd -D 2)"$normal"

      set -l git_info ""
      if set -l git_output (fish_git_prompt "$blue git:($magenta%s$blue)$normal ")
          set git_info "$git_output"
      end

      set -l mode_indicator '?'

      switch $fish_bind_mode
          case default
              set mode_indicator "$yellow"N
          case insert
              set mode_indicator "$green"I
          case replace_one
              set mode_indicator "$magenta"R
          case visual
              set mode_indicator "$red"V
      end

      set -l prompt_color $green
      if test $status -ne 0
          set prompt_color $red
      end

      set -l prompt_symbol "$prompt_color❯$normal "

      printf "%s%s\n%s %s" $current_dir $git_info $mode_indicator $prompt_symbol
    '';
  };
}
