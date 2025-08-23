{ config, ... }:
{

  boot = {
    kernelParams = [ "amd_pstate=active" ];
    kernelModules = [
      "zenpower"
      "kvm-amd"
    ];
    availableKernelModules = [
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
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      nvidiaSettings = true;
      modesetting.enable = true;
      powerManagement.finegrained = true;
    };

    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/670e2eaf-b150-4e63-b265-63931ffe00a5";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5202-B442";
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
}
