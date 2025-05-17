{ config, ... }:

{
  programs.git = {
    enable = true;

    userName = "Rashid J. Almheiri";
    userEmail = "r.muhairi@pm.me";

    extraConfig = {
      init.defaultBranch = "trunk";

      commit.gpgsign = true;
      tag.gpgsign = true;

      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";

      core.editor = "em";
    };

    patdiff.enable = true;
  };
}
