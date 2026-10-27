{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  xdg.configFile."fish/themes/impaled-nazarene.theme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/metalelf0/black-metal-theme-neovim/1838337ce73a8de38e81bc40abe54f07b2380273/extras/fish_themes/impaled-nazarene.theme";
    sha256 = "8s99eKeVfXPm7FS3q6BB3Sz6Cu1MC6aPh5JmRqh0avY=";
  };

  programs.fish = {
    enable = true;

    shellAliases.x =
      mkIf config.programs.emacs.enable
      <| toString (
        pkgs.writeScript "emacsclient" ''${config.programs.emacs.finalPackage}/bin/emacsclient -c "$@"''
      );

    shellInit = ''
      set fish_greeting
      set fish_key_bindings fish_vi_key_bindings
      fish_config theme choose impaled-nazarene
    '';

    # Dedicated debug Chromium (isolated profile) with the DevTools port open so
    # pi's chrome-devtools MCP (attach mode, --browserUrl 127.0.0.1:9222) can
    # connect. Backgrounded + disowned so it detaches from the launching terminal.
    functions.chrome-debug = {
      description = "Launch dedicated debug Chromium (DevTools :9222) for pi's chrome MCP";
      body = ''
        chromium --remote-debugging-port=9222 --user-data-dir=$HOME/.chrome-pi $argv >/dev/null 2>&1 &
        disown
      '';
    };

    # Separate Claude Code profiles: isolated creds/history/settings per account.
    # Both were seeded from ~/.claude so behaviour is identical; log the second
    # account in with e.g. `claude-work auth login`.
    functions.claude-work = {
      description = "Claude Code with work account (CLAUDE_CONFIG_DIR=~/.claude-work)";
      body = ''
        CLAUDE_CONFIG_DIR=$HOME/.claude-work command claude $argv
      '';
    };

    functions.claude-personal = {
      description = "Claude Code with personal account (CLAUDE_CONFIG_DIR=~/.claude-personal)";
      body = ''
        CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude $argv
      '';
    };

    # Second subscription: isolated creds/history/settings. Seed once from
    # ~/.claude if you want identical behaviour, then log in with
    # e.g. `claude-v2 auth login`.
    functions.claude-v2 = {
      description = "Claude Code with second subscription (CLAUDE_CONFIG_DIR=~/.claude-v2)";
      body = ''
        CLAUDE_CONFIG_DIR=$HOME/.claude-v2 command claude $argv
      '';
    };

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
