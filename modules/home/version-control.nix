{ config, ... }:
let
  user = {
    name = "Rashid J. Almheiri";
    email = "r.muhairi@pm.me";
  };
in
{
  programs.mergiraf.enable = true;
  programs.git = {
    enable = true;

    userName = user.name;
    userEmail = user.email;

    aliases.st = "status";
    patdiff.enable = true;

    signing = {
      key = "~/.ssh/id";
      format = "ssh";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "trunk";

      commit.verbose = true;

      log.date = "iso";
      column.ui = "auto";

      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      pull = {
        rebase = true;
        autoSetupRemote = true;
      };

      merge.conflictStyle = "zdiff3";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
        rerere.enabled = true;
      };

      commit.gpgSign = true;
      tag.gpgSign = true;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      core.fsmonitor = "watchman";

      inherit user;

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        backends.ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };

      ui = {
        editor = "hx";
        pager = "delta";

        log-word-wrap = true;

        diff.tool = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
