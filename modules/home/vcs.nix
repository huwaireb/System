{ config, ... }:
let
  user = {
    name = "Rashid J. Almheiri";
    email = "r.muhairi@pm.me";
  };
in
{
  programs.git = {
    enable = true;

    userName = user.name;
    userEmail = user.email;

    extraConfig = {
      init.defaultBranch = "master";

      commit.gpgsign = true;
      tag.gpgsign = true;

      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";

      core.editor = "hx";
    };

    delta.enable = true;
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
