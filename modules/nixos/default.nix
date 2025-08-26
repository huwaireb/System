{
  imports = [
    ./gtk.nix
    ./kernel.nix
  ];

  boot.tmp.cleanOnBoot = true;

  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback
  '';
}
