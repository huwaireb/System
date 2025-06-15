{
  programs.mergiraf.enable = true;
  programs.git = {
    enable = true;

    userName = "Rashid Almheiri";
    userEmail = "pub@rmu.ae";

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
}
