{
  config,
  pkgs,
  ...
}:
let
  user = {
    name = "Rashid J. Almheiri";
    email = "r.muhairi@pm.me";
  };
in
{
  home.packages = [
    pkgs.difftastic
    pkgs.gh
  ];

  programs.mergiraf = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.background = "dark";
  };

  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id";
      format = "ssh";
      signByDefault = true;
    };

    settings = {
      user = {
        name = user.name;
        email = user.email;
      };

      alias.st = "status";

      init.defaultBranch = "trunk";

      commit = {
        verbose = true;
        gpgSign = true;
      };

      log.date = "iso";

      column.ui = "auto";

      branch.sort = "-committerdate";

      tag = {
        sort = "version:refname";
        gpgSign = true;
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      pull = {
        rebase = true;
        autoSetupRemote = true;
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
        rerere.enabled = true;
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      fsmonitor.backend = "watchman";

      inherit user;

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id.pub";
        backends.ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };

      ui = {
        editor = "hx";

        log-word-wrap = true;

        diff-editor = ":builtin";
        diff-formatter = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
