{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ControlMaster = "auto";
        ControlPath = "/tmp/ssh-%r@%n:%p";
        ControlPersist = "60m";
        ServerAliveCountMax = 2;
        ServerAliveInterval = 60;
        Compression = true;
        HashKnownHosts = true;
        SetEnv = {
          COLORTERM = "truecolor";
          TERM = "xterm-256color";
        };
        IdentityFile = "~/.ssh/id";
      };
    };
  };
}
