{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) range flatten;
in
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  xdg.portal = {
    enable = true;
    config.common.default = "*";

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];

    configPackages = [
      pkgs.hyprland
    ];
  };

  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland = {
        systemd.enable = true;
        systemd.enableXdgAutostart = true;

        settings = {
          bind = flatten [
            (
              map (n: [
                "SUPER      , ${toString n}, workspace            , ${toString n}"
                "SUPER+SHIFT, ${toString n}, movetoworkspacesilent, ${toString n}"
              ])
              <| range 1 7
            )

            "SUPER+SHIFT, m, movewindow, l"
            "SUPER+SHIFT, n, movewindow, d"
            "SUPER+SHIFT, e, movewindow, u"
            "SUPER+SHIFT, i, movewindow, r"

            "SUPER      , Q, killactive"
            "SUPER      , F, fullscreen"
            "SUPER+SHIFT, F, togglefloating"

            "SUPER, RETURN, exec, ghostty --gtk-single-instance=true"
            "SUPER, C     , exec, hyprpicker --autocopy"

            "     , PRINT, exec, pkill grim; grim -g \"$(slurp -w 0)\" - | swappy -f - -o - | wl-copy --type image/png"
            "SHIFT, PRINT, exec, pkill grim; grim                      - | swappy -f - -o - | wl-copy --type image/png"
          ];

          binde = [
            "SUPER, m, movefocus, l"
            "SUPER, n, movefocus, d"
            "SUPER, e, movefocus, u"
            "SUPER, i, movefocus, r"

            "SUPER+CTRL, m, resizeactive, -100 0"
            "SUPER+CTRL, n, resizeactive, 0 100"
            "SUPER+CTRL, e, resizeactive, 0 -100"
            "SUPER+CTRL, i, resizeactive, 100 0"
          ];

          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:274, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 0;
          };

          animations = {
            bezier = [ "material_decelerate, 0.05, 0.7, 0.1, 1" ];
            animation = [
              "border    , 1, 2, material_decelerate"
              "fade      , 1, 2, material_decelerate"
              "layers    , 1, 2, material_decelerate"
              "windows   , 1, 2, material_decelerate, popin 80%"
              "workspaces, 1, 2, material_decelerate"
            ];
          };

          misc = {
            animate_manual_resizes = true;

            disable_hyprland_logo = true;
            disable_splash_rendering = true;

            key_press_enables_dpms = true;
            mouse_move_enables_dpms = true;
          };

          cursor = {
            hide_on_key_press = true;
            inactive_timeout = 10;
            no_warps = true;
          };

          dwindle = {
            preserve_split = true;
            smart_resizing = false;
          };
        };
      };
    }
  ];
}
