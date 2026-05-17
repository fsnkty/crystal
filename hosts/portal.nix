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
      gnome-minimal = true;
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
  
  users.users.main = {
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [
      alacritty
      firefox
      vscode
      vim
      wget
      ];
  };

  programs.steam.enable = true;

  services.fstrim.enable = true;
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        intel-media-driver
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-vaapi-driver
      ];
    };
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "i965"; };
  boot = {
    kernelParams = [ "i915.enable_guc=2" ];
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader.efi.canTouchEfiVariables = true;
    initrd = {
      kernelModules = [ "kvm-intel" "i915" ];
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