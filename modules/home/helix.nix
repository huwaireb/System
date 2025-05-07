{
  home.sessionVariables.EDITOR = "hx";
  programs.helix = {
    enable = true;

    languages.language-server.buck2 = {
      command = "buck2";
      args = [ "lsp" ];
    };

    languages.language = [
      {
        name = "starlark";
        auto-format = true;
        language-servers = [ "buck2" ];
        file-types = [
          "bzl"
          { glob = "BUCK"; }
          { glob = "BUILD"; }
        ];
        formatter.command = "buildifier";
      }
      {
        name = "nix";
        auto-format = true;
        formatter.command = "nixfmt";
      }
      {
        name = "c";
        file-types = [
          "c"
          "h"
        ];
        language-servers = [ "clangd" ];
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
    ];

    themes.gruvbox_ts = {
      inherits = "gruvbox_dark_soft";
      "ui.background" = { };
      "ui.text" = { };
      "ui.linenr".fg = "#6a6f99";
      "ui.bufferline.background" = { };
    };

    settings = {
      theme = "gruvbox_ts";

      editor = {
        line-number = "relative";

        auto-format = true;
        scrolloff = 5;
        color-modes = true;
        cursorline = true;
        idle-timeout = 1;
        completion-replace = true;
        true-color = true;

        shell = [
          "nu"
          "-c"
        ];

        soft-wrap.enable = true;

        bufferline = "always";

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        whitespace = {
          render = "all";
          characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⤶";
          };
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

        indent-guides.render = true;
      };
    };
  };
}
