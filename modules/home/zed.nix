{
  programs.zed-editor = {
    enable = true;

    userSettings = {
      theme = "Gruvbox Dark";
      "experimental.theme_overrides" = {
        "background.appearance" = "blurred";
        "background" = "#09090bBB";
        "panel.background" = "#00000000";
        "editor.background" = "#00000000";
        "tab_bar.background" = "#00000000";
        "terminal.background" = "#00000000";
        "toolbar.background" = "#00000000";
        "tab.inactive_background" = "#00000000";
        "tab.active_background" = "#3f3f4650";
        "border" = "#00000000";
        "status_bar.background" = "#09090bBB";
        "title_bar.background" = "#09090bBB";
        "border.variant" = "#00000000";
        "scrollbar.track.border" = "#00000000";
        "scrollbar.thumb.border" = "#00000000";
        "elevated_surface.background" = "#90";
        "surface.background" = "#90";
        "editor.active_line_number" = "#ffffffcc";
        "editor.gutter.background" = "#00000000";
        "editor.indent_guide" = "#ffffff30";
        "editor.indent_guide_active" = "#ffffff80";
        "editor.line_number" = "#ffffff80";
        "editor.active_line.background" = "#3f3f4640";
      };

      project_panel.dock = "right";

      ui_font_size = 13.8;
      buffer_font_size = 22.0;
      buffer_font_family = "Iosevka Nerd Font";
      ui_font_family = "SF Pro Display";
      "unstable.ui_density" = "compact";
      vertical_scroll_margin = 10;

      remove_trailing_whitespace_on_save = true;
      buffer_line_height = "standard";
      indent_guides = {
        enabled = true;
        line_width = 1;
        active_line_width = 1;
      };

      vim_mode = true;
      vim = {
        default_mode = "helix_normal";
        use_system_clipboard = "always";
        use_multiline_find = true;
        use_smartcase_find = true;
      };

      features = {
        copilot = true;
        edit_prediction_provider = "copilot";
      };

      assistant = {
        enable_experimental_live_diffs = true;

        default_model = {
          provider = "copilot_chat";
          model = "claude-3-5-sonnet";
        };

        version = "2";
      };

      load_direnv = "shell_hook";

      terminal = {
        line_height = "standard";
        shell.program = "nu";
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];

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
