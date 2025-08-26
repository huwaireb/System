{
  home-manager.sharedModules = [
    {
      services.dunst = {
        enable = true;

        settings.global = {
          width = "(300, 900)";

          gap_size = 5;
          corner_radius = 8;
          padding = 10;
        };

        settings.urgency_low = {
          background = "#16161e";
          foreground = "#c0caf5";
          frame_color = "#c0caf5";
        };

        settings.urgency_normal = {
          background = "#1a1b26";
          foreground = "#c0caf5";
          frame_color = "#c0caf5";
        };

        settings.urgency_critical = {
          background = "#292e42";
          foreground = "#db4b4b";
          frame_color = "#db4b4b";
        };
      };
    }
  ];
}
