{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
{
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

  programs.helix = {
    enable = true;

    languages = {
      language-server.buf = {
        command = "buf";
        args = [
          "beta"
          "lsp"
        ];
      };

      language-server.clangd-custom = {
        command = "clangd";
        args = [
          "--background-index"
          "--clang-tidy"
        ];
      };

      language-server.starpls = {
        command = "starpls";
        args = [
          "server"
          "--experimental_infer_ctx_attributes"
          "--experimental_enable_label_completions"
          "--experimental_use_code_flow_analysis"
        ];
      };

      language = [
        {
          name = "elixir";
          auto-format = true;
        }
        {
          name = "heex";
          auto-format = true;
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "protobuf";
          auto-format = true;
          language-servers = [ "buf" ];
        }
        {
          name = "ocaml";
          auto-format = true;
        }
        {
          name = "c";
          file-types = [
            "c"
            "h"
          ];
          language-servers = [ "clangd-custom" ];
          auto-format = true;
        }
        {
          name = "cpp";
          auto-format = true;
          file-types = [
            "cpp"
            "cc"
            "hh"
            "hpp"
            "ccm"
          ];
        }
        {
          name = "starlark";
          auto-format = true;
          formatter.command = "buildifier";
          language-servers = [ "starpls" ];
        }
        {
          name = "ini";
          file-types = [
            "ini"
            { glob = ".buckconfig"; }
          ];
        }
        {
          name = "python";
          language-servers = [ "pyright" ];
        }
      ];
    };

    themes.tokyonight_ts = {
      inherits = "gruvbox_dark_soft";
      "ui.background" = { };
      "ui.text" = { };
      "ui.linenr".fg = "#6a6f99";
      "ui.bufferline.background" = { };
    };

    settings = {
      theme = "tokyonight_ts";

      editor = {
        line-number = "relative";

        auto-format = true;
        scrolloff = 5;
        color-modes = true;
        cursorline = true;
        idle-timeout = 1;
        true-color = true;
        shell = [
          "nu"
          "-c"
        ];

        soft-wrap.enable = true;
        completion-replace = true;

        bufferline = "always";

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        whitespace.render = "all";
        whitespace.characters = {
          space = "·";
          nbsp = "⍽";
          tab = "→";
          newline = "⤶";
        };

        gutters = [
          "diagnostics"
          "line-numbers"
          "spacer"
          "diff"
        ];
        statusline = {
          separator = "|";
          left = [
            "mode"
            "selections"
            "spinner"
            "file-name"
            "total-line-numbers"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "file-encoding"
            "file-line-ending"
            "file-type"
            "position-percentage"
            "position"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        indent-guides = {
          render = true;
        };
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Rashid J. Almheiri";
    userEmail = "r.muhairi@pm.me";

    extraConfig = {
      init.defaultBranch = "master";
      safe.directory = [ "/etc/nixos" ];

      commit.gpgsign = true;
      tag.gpgsign = true;

      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";

      core.editor = "hx";
    };

    delta.enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      core.fsmonitor = "watchman";

      user = {
        name = "Rashid J. Almheiri";
        email = "r.muhairi@pm.me";
      };

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        backends.ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };

      ui = {
        editor = "hx";
        pager = "delta";

        log-word-wrap = true;

        diff.tool = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };

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
    configFile.text = readFile ./cfg/nu/config.nu;
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

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;

    nix-direnv.enable = true;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
