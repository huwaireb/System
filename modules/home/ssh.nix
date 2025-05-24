{ lib, pkgs, ... }:
let
  inherit (pkgs) stdenv;

  sk-libfido2 =
    let
      inherit (pkgs) openssh;
    in
    stdenv.mkDerivation {
      pname = "sk-libfido2";

      inherit (openssh) preConfigure src version buildInputs nativeBuildInputs;
      
      strictDeps = true;
      enableParallelBuilding = true;

      configureFlags = (openssh.configureFlags or []) ++ ["--with-security-key-standalone"];

      buildPhase = "make sk-libfido2.dylib";
      installPhase = "install sk-libfido2.dylib -Dt $out/lib";

      doCheck = false;
      meta.platforms = lib.platforms.darwin;
    };
in
{
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPath = "/tmp/ssh-%r@%n:%p";
    controlPersist = "60m";
    serverAliveCountMax = 2;
    serverAliveInterval = 60;
    compression = true;
    hashKnownHosts = true;

    extraConfig = lib.optionalString stdenv.isDarwin "SecurityKeyProvider ${sk-libfido2}/lib/sk-libfido2.dylib";

    matchBlocks = {
      "*" = {
        setEnv.COLORTERM = "truecolor";
        setEnv.TERM = "xterm-256color";
        identityFile = "~/.ssh/id";
      };
    };
  };
}
