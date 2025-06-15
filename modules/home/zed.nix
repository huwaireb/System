{
  programs.zed-editor = {
    userSettings = {
      theme = "Gruvbox Material";
      project_panel.dock = "right";

      ui_font_size = 16;
      buffer_font_size = 18;
      buffer_font_family = "Iosevka Nerd Font";
      ui_font_family = "SF Pro Display";
      "unstable.ui_density" = "compact";
      vertical_scroll_margin = 10;

      remove_trailing_whitespace_on_save = true;
      buffer_line_height = "standard";

      vim_mode = true;
      vim = {
        default_mode = "helix_normal";
        use_system_clipboard = "always";
        use_multiline_find = true;
        use_smartcase_find = true;
      };

      features.edit_prediction_provider = "copilot";

      terminal = {
        line_height = "standard";
        shell.program = "fish";
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];

      agent = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "copilot_chat";
          model = "claude-sonnet-4";
        };
      };

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
    ];
  };
}
