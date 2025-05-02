{ lib }:
{
  system.defaults.dock = {
    autohide = true;

    show-recents = false;
    mru-spaces = false;

    minimize-to-application = true;

    orientation = "bottom";

    persistent-apps = lib.mkDefault [
      { app = "/Applications/Safari.app"; }
    ];
  };
}
