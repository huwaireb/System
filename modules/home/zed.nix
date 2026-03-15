{ lib, pkgs, ... }:
let
  inherit (pkgs) stdenv writeScriptBin;
  is-darwin = stdenv.hostPlatform.isDarwin;
in
{
  programs.zed-editor = {
    package = lib.mkIf is-darwin (writeScriptBin "not-zed" "");
    installRemoteServer = pkgs.stdenv.isLinux;
    userSettings = {
      theme = "Catppuccin Espresso (Blur)";
      project_panel.dock = "right";

      ui_font_size = 16;
      buffer_font_size = 18;
      buffer_font_family = "Iosevka Nerd Font";
      ui_font_family = "SF Pro Display";
      "unstable.ui_density" = "compact";
      vertical_scroll_margin = 10;

      remove_trailing_whitespace_on_save = true;
      buffer_line_height = "standard";

      helix_mode = true;
      vim = {
        use_system_clipboard = "always";
        use_smartcase_find = true;
      };

      features.edit_prediction_provider = "zed";

      terminal = {
        line_height = "standard";
        shell.program = "fish";
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];

      languages.Starlark.language_servers = [
        "buck2-lsp"
        "!starpls"
      ];

      languages.Starlark.formatter = [ { external.command = "buildifier"; } ];

      lsp."protobuf-language-server".binary = {
        path = "buf";
        arguments = [
          "lsp"
          "serve"
        ];
      };

      agent.enabled = true;

      inlay_hints.enabled = true;

      calls.mute_on_join = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };

    extensions = [
      "swift"
      "html"
      "toml"
      "zig"
      "ocaml"
      "nix"
      "proto"
      "zed-catpuccin-blur"
    ];
  };
}
