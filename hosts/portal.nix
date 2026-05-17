{ pkgs, ... }:
{
  system = {
    cleanup = true;
    nix = true;
    nz = true;
    desktop = {
      darkmode = true;
      fonts = true;
      audio = true;
      plymouth = true;
      dont-wait-network = true;
      t460sfingerprint.enable = true;
    };
  };
  server.networking.ssh = true;
  users = {
    mainSetup = true;
    disableRoot = true;
    shell = {
      setup = true;
      prompt = "'%F{red}%m%f %~ %# '";
    };
    git.setup = true;
  };
  networking = {
    hostName = "portal";
    networkmanager.enable = true;
  };

  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  
  users.users.main = {
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [
      firefox
      vscode
      vim
      wget
      sbctl
    ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader.efi.canTouchEfiVariables = true;
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      systemd.enable = true;
      luks.devices = {
        "rootcrypt" = {
          device = "/dev/disk/by-uuid/4b906d09-a291-448f-b93f-ad8688ef6a6d";
          crypttabExtraOpts = [ "tpm-device=auto" ];
        };
        "swapcrypt" = {
          device = "/dev/disk/by-uuid/d4ef99d7-eeb8-4a9b-bfee-c9f4bf45cfe0";
          crypttabExtraOpts = [ "tpm-device=auto" ];
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/rootcrypt";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/52A5-10D0";
      fsType = "vfat";
      options = [ "rw" "noatime" "fmask=0077" "dmask=0077" "x-systemd.automount" ];
    };
  };
  swapDevices = [{ device = "/dev/mapper/swapcrypt"; }];

  system.stateVersion = "25.11";
}