{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        controlMaster = "auto";
        controlPath = "/tmp/ssh-%r@%n:%p";
        controlPersist = "60m";
        serverAliveCountMax = 2;
        serverAliveInterval = 60;
        compression = true;
        hashKnownHosts = true;
        setEnv.COLORTERM = "truecolor";
        setEnv.TERM = "xterm-256color";
        identityFile = "~/.ssh/id";
      };
    };
  };
}
