{
  modulesPath,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  crystal = {
    system = {
      cleanup = true;
      nix.setup = true;
      timezone.nz = true;
      hardware = {
        cpu.amd.enable = true;
        gpu.amd.enable = true;
      };
    };
    users = {
      main = {
        setup = true;
        shell = {
          setup = true;
          prompt = "'%F{red}%m%f %~ %# '";
        };
        git.setup = true;
      };
      root.disable = true;
    };
    desktop = {
      kde-std.enable = true;
      darkmode.enable = true;
      fonts.setup = true;
      audio.setup = true;
      plymouth.setup = true;
      fastboot.enable = true;
      gaming = {
        steam.enable = true;
        thunderStore.enable = true;
        prism.enable = true;
      };
    };
  };
  
  networking = {
    useNetworkd = true;
    enableIPv6 = true;
    useDHCP = false;
    hosts = {
      "119.224.63.166" = [ "library" ];
      "192.168.0.121" = [ "portal" ];
    };
  };
  systemd.network = {
    enable = true;
    networks.enp39s0 = {
      name = "enp39s0";
      dns = [ "1.1.1.1" ];
      address = [ "192.168.0.4/24" ];
      routes = [ { Gateway = "192.168.0.1"; } ];
    };
  };
  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      alacritty
      chromium
      vscodium
      discord
      proton-pass
      protonmail-desktop
      ;
  };

  hardware.bluetooth.enable = true;

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    kernelParams = [
      # faster init for RNG, saves 1~s on boot
      "random.trust_cpu=on"
      # hopefully reduce mode switching
      "video=DP-1:1920x1080@144"
    ];
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices."root" = {
        device = "/dev/disk/by-label/rootcrypt";
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/games" = {
      device = "/dev/disk/by-label/games";
      fsType = "ext4";
      options = [
        "x-systemd.automount"
      ];
    };
    "/library" = {
      device = "//library/storage";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=/keys/librarysmb"
        "uid=${toString config.users.users.main.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };
  system.stateVersion = "26.05";
}
