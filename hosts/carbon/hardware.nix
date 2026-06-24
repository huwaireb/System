{
  pkgs,
  config,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/hardware/cpu/intel-npu.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a26f6966-0f49-42dc-b6ee-3c2fd0ce1cec";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6E33-90FB";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8d28817f-5eb9-42da-ad2d-724ec74a7723"; }
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # nixos-hardware
  hardware.trackpoint.device = "TPPS/2 Synaptics TrackPoint";

  services.thermald.enable = true;

  hardware.intelgpu = {
    driver = "xe";
    vaapiDriver = "intel-media-driver";
  };
}
