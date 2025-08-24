{ config, lib, ... }:
{

  boot = {
    kernelParams = [ "amd_pstate=active" ];
    kernelModules = [
      "zenpower"
      "kvm-amd"
    ];
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    blacklistedKernelModules = [ "k10temp" ];
    extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  };

  services = {
    fstrim.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };

  hardware = {
    enableRedistributableFirmware = true;

    graphics.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      nvidiaSettings = true;
      modesetting.enable = true;
      powerManagement.enable = true;
    };

    cpu.amd.updateMicrocode = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFIBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    networks."1-UPLINK" = {
      matchConfig.Name = "eno1";
      networkConfig.DHCP = "yes";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];
}
