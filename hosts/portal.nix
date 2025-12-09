{ pkgs, ... }:
{
  system.stateVersion = "25.05";

  common = {
    lockdown = true;
    cleanup = true;
    nix = true;
    nz = true;
    shell.enable = true;
  };
  desktop.gnome = {
    enable = true;
    cleanup = true;
    config = true;
  };

  users.users.main = {
    isNormalUser = true;
    name = "fsnkty";
    description = "Madison";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vim
      wget
      vscode
      firefox
      nautilus
      snapshot
      alacritty
    ];
  };

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  networking = {
    hostName = "t460s";
    networkmanager.enable = true;
  };

  security.rtkit.enable = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    };
    kernelModules = [ "kvm-intel" ];
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/2906-7F1F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/30981d97-ba12-4c25-9e69-ff8874a2d9d2";
      fsType = "ext4";
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/238ef32e-be79-4dce-8fd9-c1a5a9b39f9e"; }
  ];
}
