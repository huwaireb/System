{
  home-manager.sharedModules = [
    {
      programs.fuzzel = {
        enable = true;
        settings.main = {
          tabs = 4;
          terminal = "ghostty -e";

          layer = "overlay";
          prompt = ''"❯ "'';

          font = "Iosevka Nerd Font";

          inner-pad = 10;
          vertical-pad = 15;
          horizontal-pad = 15;
        };

        settings.colors = {
          background = "16161eff";
          text = "c0caf5ff";
          match = "2ac3deff";
          selection = "343a55ff";
          selection-match = "2ac3deff";
          selection-text = "c0caf5ff";
          border = "27a1b9ff";
        };
      };
    }
  ];
}
