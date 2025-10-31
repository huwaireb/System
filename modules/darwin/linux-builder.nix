{
  nix.linux-builder = {
    
    ephemeral = true;
    systems = [ "aarch64-linux" ];
    supportedFeatures = [
      "benchmark"
      "kvm"
      "big-parallel"
      "nixos-test"
    ];
    config.virtualisation = {
      cores = 8;
      darwin-builder.diskSize = 100 * 1024;
      darwin-builder.memorySize = 8 * 1024;
    };
    enable = false;
  };

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
}
